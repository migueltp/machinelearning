# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 15:58:56 2016

@author: miguelserrano
"""

import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
from mpl_toolkits.mplot3d import Axes3D


matplotlib.style.use('ggplot') # Look Pretty
student_dataset = pd.read_csv("../Datasets/students.data", index_col=0)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.set_xlabel('Final Grade')
ax.set_ylabel('First Grade')
ax.set_zlabel('Daily Alcohol')

ax.scatter(student_dataset.G1, student_dataset.G3, student_dataset['Dalc'], c='r', marker='.')
plt.show()