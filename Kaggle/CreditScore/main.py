# -*- coding: utf-8 -*-

import pandas as pd
import os
from time import time
import math
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

from sklearn.decomposition import PCA
from sklearn.cross_validation import train_test_split
from sklearn import preprocessing, grid_search
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
import sklearn.metrics as metrics
from helpers import runModel, report, drawVectors


### Read Data

p = '/home/miguelserrano/Projects/Data/Kaggle/CreditScoring/cs-training.csv'
train = pd.read_csv(p)
train.dtypes




### Pre Processing

# Let's drop NA's first (150000 --> 120269 rows)
#train = train.dropna(axis=0)
train = train.fillna(train.mean())
train_lab = train.SeriousDlqin2yrs

# Let's create new variables
train['has_dependents'] = 0
train['has_dependents'][train.NumberOfDependents != 0] = 1

train['late_90_days'] = 0
train['late_90_days'][train.NumberOfTimes90DaysLate != 0] = 1

train['income_per_capita'] = train.MonthlyIncome
train.loc[train.NumberOfDependents > 0, 'income_per_capita'] = train.MonthlyIncome/train.NumberOfDependents
        
bins = [-1, 0.01, 0.25, 0.50, 0.75, 1]
group_names = ['None', 'Low', 'Okay', 'Good', 'Great']
# train['unsecured_credit_lvl'] = pd.cut(train['RevolvingUtilizationOfUnsecuredLines'],
#                                                            bins, labels=group_names)
#train.hist(column='unsecured_credit_lvl')
#pd.value_counts(train['unsecured_credit_lvl']).plot(kind='bar')

# Remove label column
train = train.drop(['Unnamed: 0', 'SeriousDlqin2yrs'], axis=1)
    
# Let's scale these features
scaled = preprocessing.scale(train)
train = pd.DataFrame(scaled, columns=train.columns)



### Data Visualization

# Simple Count by Label
t = float(train_lab.value_counts()[1]) / float(sum(train_lab.value_counts()))
print 'Percentage of Overdue(risky) Credits:', round(t * 100, 2), '%'

# PCA
# TODO: Class is unblanaced, we should discard over represented records
# that are coehese.

plot_pca = False

if plot_pca:
    
    labels = ['red' if i == 1 else 'green' for i in train_lab]
    pca = PCA(n_components=2)
    pca.fit(train)
    PCA(copy=True, whiten=False)
    T = pca.transform(train)
    T = T[0:1000]

    ax = drawVectors(T, pca.components_, train.columns.values, plt)
    T = pd.DataFrame(T)
    T.columns = ['component1', 'component2']
    T.plot.scatter(x='component1', y='component2', marker='o',
                   c=labels, alpha=0.75, ax=ax)
    plt.show()




### Split Data
X_train, X_test, y_train, y_test = train_test_split(train,
                                                    train_lab,
                                                    test_size=0.3,
                                                    random_state=7)

### Model

# SVM as first approach
g = 0.01
c = 10
model = SVC(C=c, gamma=g, kernel='rbf',
            class_weight='balanced',
            probability=True)


#model = runModel(model=model, X_train=X_train[0:20000], y_train=y_train[0:20000],
#                 optimize=optimize, parameters=0, scoring='roc_auc')

parameters = {'kernel': ['rbf'], 'C': [5, 10, 25], 'gamma': [0.1, 0.01, 0.001]}

model = SVC(class_weight='balanced', probability=True)
model = runModel(model=model, X_train=X_train[0:20000], y_train=y_train[0:20000],
                 optimize=True, parameters=parameters, scoring='roc_auc')

#print 'Model Optimization =', True
#print "Fitting RandomForestClassifier ..."
#start = time()
#parameters = {'n_estimators': [50, 100, 200], 'max_depth': [10, 25],
#              'min_samples_leaf': [2, 5, 10], 'oob_score': [True, False]}
#
#model = RandomForestClassifier(random_state=7, class_weight='balanced')
#classifier = grid_search.GridSearchCV(model, parameters, n_jobs=4,
#                                      refit=True, scoring='roc_auc')
#
#classifier.fit(X_train, y_train)
#report(classifier.grid_scores_, n_top=5)
#model = model.best_estimator_
#model.fit(X_train, y_train)
#print("RandomForestClassifier took %.2f seconds to fit" % (time() - start))

#
#
#print "Fitting GradientBoostingClassifier..."
#start = time()
#model = SVC(C=10, gamma=0.01, kernel='rbf',
#            class_weight='balanced',
#            probability=True)
#
#classifier = GradientBoostingClassifier(loss='exponential', learning_rate=0.1,
#                                        n_estimators=100, max_depth=3,
#                                        min_samples_leaf=10, random_state=7,
#                                        max_features=None, verbose=1)
#classifier.fit(X_train, y_train)
#print("GradientBoostingClassifier took %.2f seconds to fit" % (time() - start))


print "Applying Classifier..."
start = time()
y_pred = model.predict(X_test)
print("SVM took %.2f seconds to predict vals" % (time() - start))


### Evaluation
print "Scoring Classifier..."
start = time()
score = model.score(X_test, y_test)

# Class Recall
recall = metrics.recall_score(y_test, y_pred, average='binary')

# Area under curve
auc = metrics.roc_auc_score(y_test, y_pred, average='macro')

# Confusion Matrix
confusion = metrics.confusion_matrix(y_test, y_pred, labels=[0, 1])

print "Score: \t \t Recall: \t AUC:\n", score, recall, auc
print("SVM took %.2f seconds to score" % (time() - start))


# ROC Curves
plot_roc = True

if plot_roc:
    
    fpr, tpr, thrsh = metrics.roc_curve(y_test, y_pred, pos_label=1)
    
    plt.figure()
    plt.plot(fpr, tpr, label='ROC curve (area = %0.2f)' % auc)
    plt.plot([0, 1], [0, 1], 'k--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver operating characteristic example')
    plt.legend(loc="lower right")
    plt.show()


### Submission
p = '/home/miguelserrano/Projects/Data/Kaggle/CreditScoring/cs-test.csv'
test = pd.read_csv(p)
test = test.drop(['Unnamed: 0', 'SeriousDlqin2yrs'], axis=1)


# New Vars
test['has_dependents'] = 0
test['has_dependents'][test.NumberOfDependents != 0] = 1

test['late_90_days'] = 0
test['late_90_days'][train.NumberOfTimes90DaysLate != 0] = 1

test['income_per_capita'] = test.MonthlyIncome
test.loc[test.NumberOfDependents > 0, 'income_per_capita'] = test.MonthlyIncome/test.NumberOfDependents


# Fill Nans with mean
test = test.fillna(test.mean())


# Scale vals
scaled = preprocessing.scale(test)
test = pd.DataFrame(scaled, columns=test.columns)


# Apply Prediction
print "Applying SVC Classifier..."
start = time()
y_pred = model.predict_proba(test)
y_vals = model.predict(test)
print("SVM took %.2f seconds to apply" % (time() - start))


# Write csv
sub = pd.DataFrame(y_pred[:, 1], columns=['Probability'])
sub['Id'] = range(1, 101504, 1)
sub = sub[['Id', 'Probability']]
sub.to_csv('sample.csv', sep=',', index=False)
print 'Sample ready for Submission, GL!'
