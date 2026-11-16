import argparse,json,numpy as np
from pipeline import infer_int4
p=argparse.ArgumentParser();p.add_argument('--package',required=True);p.add_argument('--vectors',required=True);a=p.parse_args()
pkg=json.load(open(a.package));vec=json.load(open(a.vectors))
for i,v in enumerate(vec):
 logits,commands=infer_int4(v['input_features_normalized'],pkg,True)
 assert np.allclose(logits,v['expected_logits'],rtol=0,atol=1e-10),(i,logits,v['expected_logits'])
 assert int(np.argmax(logits))==v['expected_class']
 assert commands==v['commands']
print(f'PASS: {len(vec)} golden inference vectors, all MAC instructions and logits reproduced')
