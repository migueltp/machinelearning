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
from helpers import runModel, report, drawVectors, submission


### Config
plot_pca = False
plot_roc = False


### Read Data

r = '/home/miguelserrano/Projects/Data/Kaggle/CreditScoring/cs-training.csv'
train = pd.read_csv(r)
train.dtypes


### Pre Processing

# Let's drop NA's first (150000 --> 120269 rows)
#train = train.dropna(axis=0)
train = train.fillna(train.mean())
train_lab = train.SeriousDlqin2yrs

# Let's create new variables
train['has_dependents'] = 0
train.loc[train.NumberOfDependents != 0, 'has_dependents'] = 1
train['late_90_days'] = 0
train.loc[train.NumberOfTimes90DaysLate != 0, 'late_90_days'] = 1
train['income_per_capita'] = train.MonthlyIncome
val = train.MonthlyIncome/train.NumberOfDependents
train.loc[train.NumberOfDependents > 0, 'income_per_capita'] = val

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
parameters = {'n_estimators': [100, 200], 'max_depth': [7, 15],
              'min_samples_leaf': [5, 10], 'oob_score': [True, False]}

model = RandomForestClassifier(random_state=7, class_weight='balanced')
model = runModel(model=model, trainX=X_train[0:1000], trainY=y_train[0:1000],
                 optimize=True, parameters=parameters, scoring='roc_auc')


print "Applying Classifier..."
start = time()
y_pred = model.predict(X_test)
print("SVM took %.2f seconds to predict vals" % (time() - start))


### Evaluation
print "Scoring Classifier..."
start = time()

score = model.score(X_test, y_test)
recall = metrics.recall_score(y_test, y_pred, average='binary')
auc = metrics.roc_auc_score(y_test, y_pred, average='macro')
confusion = metrics.confusion_matrix(y_test, y_pred, labels=[0, 1])

print "Score: \t \t Recall: \t AUC:\n", score, recall, auc
print("SVM took %.2f seconds to score" % (time() - start))

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

r = '/home/miguelserrano/Projects/Data/Kaggle/CreditScoring/cs-test.csv'
w = str('/home/miguelserrano/Projects/Research/machinelearning/Kaggle/' +
        'CreditScore/sample.csv')

submission(read_path=r, model=model, write_path=w)
