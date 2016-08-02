# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 17:12:23 2016

@author: miguelserrano
"""
from sklearn.datasets import load_iris
from pandas.tools.plotting import parallel_coordinates

import matplotlib
import matplotlib.pyplot as plt
import pandas as pd


matplotlib.style.use('ggplot') # Look Pretty

# Load up SKLearn's Iris Dataset into a Pandas Dataframe
data = load_iris()
df = pd.DataFrame(data.data, columns=data.feature_names) 

df['target_names'] = [data.target_names[i] for i in data.target]

# Parallel Coordinates Start Here:
plt.figure()
parallel_coordinates(df, 'target_names')
plt.show()