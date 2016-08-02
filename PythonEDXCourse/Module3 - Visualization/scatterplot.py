# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 15:56:56 2016

@author: miguelserrano
"""

import pandas as pd
import matplotlib
import matplotlib.pyplot as plt

matplotlib.style.use('ggplot')
# matplotlib.style.use('ggplot') # Look Pretty
# If the above line throws an error, use plt.style.use('ggplot') instead

student_dataset = pd.read_csv("../Datasets/students.data", index_col=0)

student_dataset.plot.scatter(x='G1', y='G3')
