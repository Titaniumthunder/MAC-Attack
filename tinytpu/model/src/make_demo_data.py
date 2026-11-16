"""Synthetic data for a pipeline smoke test ONLY; not scientific fault evidence."""
import argparse,csv,numpy as np
p=argparse.ArgumentParser();p.add_argument('--out',default='data/demo_vibration.csv');p.add_argument('--fs',type=int,default=4000);p.add_argument('--runs-per-class',type=int,default=12);p.add_argument('--samples',type=int,default=8192);a=p.parse_args()
rng=np.random.default_rng(21)
from pathlib import Path
Path(a.out).parent.mkdir(parents=True,exist_ok=True)
with open(a.out,'w',newline='') as f:
 w=csv.writer(f);w.writerow(['sample','run_id','label'])
 for label in ['healthy','faulty']:
  for run in range(a.runs_per_class):
   t=np.arange(a.samples)/a.fs
   rpm=rng.uniform(22,35)
   x=.6*np.sin(2*np.pi*rpm*t)+.09*rng.normal(size=a.samples)
   if label=='faulty':x+=.35*np.sin(2*np.pi*310*t)+.1*rng.normal(size=a.samples)
   w.writerows((float(v),f'{label}_{run:02d}',label) for v in x)
print('Synthetic demo written:',a.out)
