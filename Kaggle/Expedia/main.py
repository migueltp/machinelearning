import pandas as pd
from time import time
from scipy.stats import binom_test

t = time()
df = pd.read_csv('/home/miguelserrano/Projects/data/Kaggle/Expedia/train.csv', nrows=100000)
# 66 sec to fit data in memory
# df = pd.read_csv('/home/miguelserrano/Projects/data/Kaggle/Expedia_Search/train.csv')
print time() - t

# Count Missing Values
df.isnull().sum() / df.shape[0] * 1.0



x = 10
y = 1000
z = 0.01

binom_test(n=)