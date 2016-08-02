import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import os

from pandas.tools.plotting import andrews_curves


# This code is intentionally missing!
# Read the directions on the course lab page!
#

df = pd.read_csv("../Datasets/wheat.data")
df = df.drop('id', axis=1)
plt.figure()
andrews_curves(df, 'wheat_type')
print df
plt.show()