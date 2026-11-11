import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import config  # noqa: F401,E402  (first: puts model/ on the path and stops .pyc files being written there)
