import pandas as pd
from time import time


t = time()
# df = pd.read_csv('/home/miguelserrano/Projects/data/Kaggle/Expedia_Search/train.csv', nrows=100)
# 66 sec to fit data in memory
df = pd.read_csv('/home/miguelserrano/Projects/data/Kaggle/Expedia_Search/train.csv')
print time() - t

