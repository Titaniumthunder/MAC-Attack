"""RSCL motor vibration -> PyTorch MLP -> custom INT4 Tiny-TPU reference.
CSV schema: sample,run_id,label, optional rpm,load; one row per time sample.
All rows of a run must share a label. Train/test splits operate on run_id.
"""
import argparse, csv, json, math, random
from pathlib import Path
import numpy as np
from scipy.stats import kurtosis, skew
from sklearn.model_selection import GroupShuffleSplit
from sklearn.metrics import accuracy_score, balanced_accuracy_score, confusion_matrix, classification_report
import torch
from torch import nn

FEATURES = ['rms','std','peak','crest','kurtosis','skew','low_band','high_band']

def features(x, fs):
    x = np.asarray(x, dtype=np.float64)
    x = x - np.mean(x)
    rms = np.sqrt(np.mean(x*x))
    spec = np.abs(np.fft.rfft(x * np.hanning(len(x))))**2
    freqs = np.fft.rfftfreq(len(x), 1.0/fs)
    # Fixed frequency bands: inspect these for the actual motor speed and sampling rate.
    low = spec[(freqs >= 10) & (freqs < 500)].sum()
    high = spec[(freqs >= 500) & (freqs < min(5000,fs/2))].sum()
    total = spec.sum() + 1e-12
    return np.array([rms, np.std(x), np.max(np.abs(x)), np.max(np.abs(x))/(rms+1e-12),
                     kurtosis(x, fisher=True, bias=False) if np.std(x)>1e-12 else 0.,
                     skew(x, bias=False) if np.std(x)>1e-12 else 0.,
                     low/total, high/total], dtype=np.float32)

def load_windows(csv_path, fs, window, hop):
    runs = {}
    with open(csv_path, newline='') as f:
        reader = csv.DictReader(f)
        needed = {'sample','run_id','label'}
        if not needed.issubset(reader.fieldnames or []):
            raise ValueError('CSV needs columns sample,run_id,label; convert Ottawa data first (see README).')
        for row in reader:
            k = row['run_id']
            if k not in runs: runs[k] = {'label':row['label'], 'values':[]}
            if runs[k]['label'] != row['label']: raise ValueError(f'Multiple labels in run {k}')
            runs[k]['values'].append(float(row['sample']))
    X=[]; y=[]; groups=[]
    for run, rec in runs.items():
        v=np.asarray(rec['values'],dtype=np.float32)
        for start in range(0,len(v)-window+1,hop):
            X.append(features(v[start:start+window],fs))
            y.append(rec['label']); groups.append(run)
    if not X: raise ValueError('No full windows. Check window size and input files.')
    return np.stack(X), np.array(y), np.array(groups)

def split(X,y,groups,seed):
    # Do not use overlapping windows from a run in multiple splits.
    splitter=GroupShuffleSplit(n_splits=1,test_size=.20,random_state=seed)
    trainval,test=next(splitter.split(X,y,groups))
    splitter2=GroupShuffleSplit(n_splits=1,test_size=.25,random_state=seed+1)
    tr_rel,val_rel=next(splitter2.split(X[trainval],y[trainval],groups[trainval]))
    return trainval[tr_rel],trainval[val_rel],test

class MLP(nn.Module):
    def __init__(self, hidden=4):
        super().__init__()
        self.layers=nn.Sequential(nn.Linear(8,hidden),nn.ReLU(),nn.Linear(hidden,2))
    def forward(self,x): return self.layers(x)

def q4_scale(a):
    m=float(np.max(np.abs(a)))
    return max(m/7.0,1e-12)

def quant4(a,scale):
    # numpy round = ties-to-even; clamp to symmetric signed INT4 [-7,7].
    return np.clip(np.rint(np.asarray(a,dtype=np.float64)/scale),-7,7).astype(np.int8)

def checked_mac16(a,w):
    """Signed 16-bit accumulator, no wrap; raises if the proposed RTL would overflow."""
    acc=0
    for ai,wi in zip(a,w):
        acc += int(ai)*int(wi)
        if not -32768 <= acc <= 32767: raise OverflowError('INT16 MAC overflow')
    return acc

def make_package(model, Xcal):
    linear=[m for m in model.layers if isinstance(m,nn.Linear)]
    W=[m.weight.detach().cpu().numpy() for m in linear]
    B=[m.bias.detach().cpu().numpy() for m in linear]
    xscale=q4_scale(Xcal)
    # Quantized layer 1 output dequantized + bias, then ReLU on HOST.
    wscale0=q4_scale(W[0]); qw0=quant4(W[0],wscale0)
    hidden=[]
    for x in Xcal:
        qx=quant4(x,xscale)
        z=np.array([checked_mac16(qx,row) for row in qw0],dtype=np.float64)*xscale*wscale0+B[0]
        hidden.append(np.maximum(z,0))
    hscale=q4_scale(np.stack(hidden))
    wscale1=q4_scale(W[1]); qw1=quant4(W[1],wscale1)
    return {'format':'rscl-int4-host-postprocess-v1', 'input_features':FEATURES,
            'activation_scales':[xscale,hscale], 'weight_scales':[wscale0,wscale1],
            'weights':[qw0.tolist(),qw1.tolist()], 'biases':[b.astype(float).tolist() for b in B],
            'quantization':'symmetric [-7,7], ties-to-even, per-layer scale',
            'accumulator':'signed INT16; reject overflow',
            'postprocess':'host dequantizes, adds float bias, applies ReLU; output argmax on host'}

def infer_int4(x,pkg,trace=False):
    a=np.asarray(x,dtype=np.float64)
    instructions=[]
    for layer in range(2):
        scale_a=pkg['activation_scales'][layer]
        qa=quant4(a,scale_a)
        outputs=[]
        for j,row in enumerate(pkg['weights'][layer]):
            instructions.append({'op':'CLEAR','layer':layer,'neuron':j})
            for av,wv in zip(qa,row):
                instructions.append({'op':'MAC','a':int(av),'w':int(wv)})
            s=checked_mac16(qa,row)
            instructions.append({'op':'READ','expected_acc':s})
            outputs.append(s*scale_a*pkg['weight_scales'][layer]+pkg['biases'][layer][j])
        a=np.array(outputs)
        if layer==0: a=np.maximum(a,0)
    return (a,instructions) if trace else a

def train(args):
    torch.set_num_threads(1)
    random.seed(args.seed);np.random.seed(args.seed);torch.manual_seed(args.seed)
    X,y,groups=load_windows(args.csv,args.fs,args.window,args.hop)
    labels=sorted(set(y.tolist()))
    if len(labels)!=2: raise ValueError(f'Binary demo needs exactly two labels, found {labels}')
    y=np.array([labels.index(v) for v in y],dtype=np.int64)
    tr,va,te=split(X,y,groups,args.seed)
    if any(len(np.unique(y[idx]))<2 for idx in (tr,va,te)):
        raise ValueError('Each split must have both classes. Collect more independent runs per class.')
    mean=X[tr].mean(0);std=X[tr].std(0);std=np.where(std<1e-8,1,std)
    X=(X-mean)/std
    model=MLP(args.hidden)
    opt=torch.optim.Adam(model.parameters(),lr=.005)
    lossfn=nn.CrossEntropyLoss()
    xt=torch.tensor(X[tr],dtype=torch.float32);yt=torch.tensor(y[tr])
    xv=torch.tensor(X[va],dtype=torch.float32);yv=torch.tensor(y[va])
    best=1e9;state=None;patience=0
    for epoch in range(args.epochs):
        model.train();order=torch.randperm(len(xt))
        for ids in order.split(64):
            opt.zero_grad();loss=lossfn(model(xt[ids]),yt[ids]);loss.backward();opt.step()
        model.eval()
        with torch.no_grad(): vl=float(lossfn(model(xv),yv))
        if vl<best-1e-5:
            best=vl;state={k:v.detach().clone() for k,v in model.state_dict().items()};patience=0
        else: patience+=1
        if patience>=30:break
    model.load_state_dict(state);model.eval()
    # Calibrate exclusively on training data, never validation or test.
    pkg=make_package(model,X[tr]);pkg['normalization']={'mean':mean.tolist(),'std':std.tolist()}
    pkg['labels']=labels;pkg['model']=[8,args.hidden,2]
    with torch.no_grad(): float_logits=model(torch.tensor(X[te],dtype=torch.float32)).numpy()
    int_logits=np.stack([infer_int4(x,pkg) for x in X[te]])
    def report(logits):
        pred=np.argmax(logits,axis=1)
        return {'accuracy':float(accuracy_score(y[te],pred)),
                'balanced_accuracy':float(balanced_accuracy_score(y[te],pred)),
                'confusion_matrix':confusion_matrix(y[te],pred,labels=[0,1]).tolist(),
                'classification_report':classification_report(y[te],pred,labels=[0,1],target_names=labels,zero_division=0,output_dict=True)}
    result={'dataset':str(args.csv),'fs':args.fs,'window':args.window,'hop':args.hop,
            'splits':{'train_windows':len(tr),'val_windows':len(va),'test_windows':len(te),
                      'train_runs':len(set(groups[tr])),'val_runs':len(set(groups[va])),'test_runs':len(set(groups[te]))},
            'float':report(float_logits),'int4':report(int_logits),
            'agreement':float(np.mean(np.argmax(float_logits,axis=1)==np.argmax(int_logits,axis=1)))}
    out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
    torch.save({'state_dict':model.state_dict(),'hidden':args.hidden,'labels':labels},out/'model.pt')
    (out/'int4_package.json').write_text(json.dumps(pkg,indent=2))
    (out/'metrics.json').write_text(json.dumps(result,indent=2))
    # Test vectors and abstract PE instruction stream, NOT a finalized GPIO byte protocol.
    vectors=[]
    for i in te[:min(12,len(te))]:
        logits,ops=infer_int4(X[i],pkg,True)
        vectors.append({'input_features_normalized':X[i].astype(float).tolist(),
                        'expected_logits':logits.tolist(),'expected_class':int(np.argmax(logits)),
                        'true_class':int(y[i]),'commands':ops})
    (out/'golden_vectors.json').write_text(json.dumps(vectors,indent=2))
    print(json.dumps({'labels':labels,'float_accuracy':result['float']['accuracy'],
                      'int4_accuracy':result['int4']['accuracy'],'agreement':result['agreement'],
                      'output':str(out)},indent=2))

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--csv',required=True);ap.add_argument('--fs',type=float,required=True)
    ap.add_argument('--window',type=int,default=2048);ap.add_argument('--hop',type=int,default=1024)
    ap.add_argument('--hidden',type=int,default=4);ap.add_argument('--epochs',type=int,default=150)
    ap.add_argument('--seed',type=int,default=42);ap.add_argument('--out',default='outputs/run1')
    args=ap.parse_args();train(args)
if __name__=='__main__':main()
