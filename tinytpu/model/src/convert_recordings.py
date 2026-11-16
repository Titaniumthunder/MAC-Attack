"""Convert one CSV per recording into long-form training CSV using a manifest.
Manifest columns: path,run_id,label,column. Paths relative to manifest directory.
The recording files must have headers and numeric vibration values in the named column.
"""
import argparse,csv
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--manifest',required=True);p.add_argument('--out',required=True);a=p.parse_args()
m=Path(a.manifest);dest=Path(a.out);dest.parent.mkdir(parents=True,exist_ok=True)
with m.open(newline='') as fi,dest.open('w',newline='') as fo:
 writer=csv.writer(fo);writer.writerow(['sample','run_id','label'])
 for rec in csv.DictReader(fi):
  path=(m.parent/rec['path']).resolve()
  with path.open(newline='') as f:
   reader=csv.DictReader(f)
   if rec['column'] not in (reader.fieldnames or []):raise ValueError(f'Missing {rec["column"]} in {path}')
   for row in reader:writer.writerow([float(row[rec['column']]),rec['run_id'],rec['label']])
print('Wrote',dest)
