import sys,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'src'))
import numpy as np
from pipeline import quant4,checked_mac16,features
class ArithmeticTests(unittest.TestCase):
 def test_quantization(self):
  self.assertEqual(quant4(np.array([-20,-7,-.5,0,.5,7,20]),1).tolist(),[-7,-7,0,0,0,7,7])
 def test_mac(self):
  self.assertEqual(checked_mac16([3,-2,1],[2,4,-1]),-3)
 def test_overflow(self):
  with self.assertRaises(OverflowError):checked_mac16([7]*700,[7]*700)
 def test_features(self):
  self.assertEqual(features(np.sin(np.arange(2048)),4000).shape,(8,))
if __name__=='__main__':unittest.main()
