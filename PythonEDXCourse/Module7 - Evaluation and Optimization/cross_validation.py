# -*- coding: utf-8 -*-
from sklearn import datasets
from sklearn.cross_validation import train_test_split


# SciKit-Learn's train_test_split() method selects a random subset of your data 
# to withhold as the testing validation set. Without a deterministic selection 
# of training data and testing data, you might train using the best subset of 
# data but test on outliers, or some permutation in-between. 
# The second issue introduced is by withholding data from training,
# you essentially lose some of your training data! Machine learning is only 
# as accurate as the data its trained upon, so generally more data means better results. 

# Neglecting to train your models on your hard collected data is like 
# refusing to take your rightful change at the bank.

# The way to overcome this is by splitting your data once more. 
# Now you have a training set, a testing set, and a validation set that you don't optimize
# your models against and only use for scoring. Such a process is too tedious. 
# Having to deal with three sets of data means you must remember to do the same 
# transformations to all sets, otherwise you'll get incorrect shape errors when fitting and training. 
# This just introduces opportunities for silly mistakes. Part of being a great programmer is 
# getting the machine to do all the tedious tasks in order to increase your efficiency as much as possible. 
# The creators of SciKit-Learn totally got that, 
# and have put together your new favorite method: cross_val_score().

# DOCUMENTATION HERE
# http://scikit-learn.org/stable/modules/cross_validation.html#cross-validation-iterators
# import some data to play with
iris = datasets.load_iris()
X = iris.data[:, :2]  # we only take the first two features.
y = iris.target


# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)


# Test how well your model can recall its training data:
from sklearn import tree 

model = tree.DecisionTreeClassifier(max_depth=9)
model.fit(X_train, y_train).score(X_train, y_train)
model.fit(X_train, y_train).score(X_test, y_test)


# 10-Fold Cross Validation on your training data
from sklearn import cross_validation as cval
cval.cross_val_score(model, X_train, y_train, cv=10)
cval.cross_val_score(model, X_train, y_train, cv=10).mean()