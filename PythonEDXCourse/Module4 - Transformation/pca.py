# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 17:27:53 2016

@author: miguelserrano
"""

from sklearn.decomposition import PCA
import pandas as pd

df = pd.read_csv("../Datasets/wheat.data")
df = df.drop(['id','wheat_type'], axis=1)

pca = PCA(n_components=2)
pca.fit(df)
PCA(copy=True, n_components=2, whiten=False)

T = pca.transform(df)

df.shape
(430, 6) # 430 Student survey responses, 6 questions..

T.shape
(430, 2) # 430 Student survey responses, 2 principal components..