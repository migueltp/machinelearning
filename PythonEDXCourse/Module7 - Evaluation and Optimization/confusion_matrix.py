# -*- coding: utf-8 -*-
import sklearn.metrics as metrics
from tabulate import tabulate




### 3 Class Example ###

y_true = [1, 1, 2, 2, 3, 3]  # Actual, observed testing dataset values
y_pred = [1, 1, 1, 3, 2, 3]  # Predicted values from your model

metrics.confusion_matrix(y_true, y_pred)

import matplotlib.pyplot as plt

columns = ['Cat', 'Dog', 'Monkey']
confusion = metrics.confusion_matrix(y_true, y_pred)


# Global Score
metrics.accuracy_score(y_true, y_pred)
metrics.accuracy_score(y_true, y_pred, normalize=False)


# Recall
# ratio of true_positives / (true_positives + false_negatives)
metrics.recall_score(y_true, y_pred, average='weighted')
metrics.recall_score(y_true, y_pred, average=None)


# Precision
# true_positives / (true_positives + false_positives)
metrics.precision_score(y_true, y_pred, average='weighted')
metrics.precision_score(y_true, y_pred, average=None)


# F1
# The F1 Score is a weighted average of the precision and recall. 
# Defined as 2 * (precision * recall) / (precision + recall), 
# the best possible result is 1 and the worst possible score is 0
metrics.f1_score(y_true, y_pred, average='weighted')
metrics.f1_score(y_true, y_pred, average=None)


# Full Report
columns = ['Fruit1', 'Fruit2', 'Fruit3']
metrics.classification_report(y_true, y_pred, target_names=columns)



# Confusion Map Plot
plt.imshow(confusion, cmap=plt.cm.Blues, interpolation='nearest')
plt.xticks([0,1,2], columns, rotation='vertical')
plt.yticks([0,1,2], columns)
plt.colorbar()

plt.show()