# -*- coding: utf-8 -*-

# GridSearchCV takes care of your parameter tuning and also tacks on 
# end-to-end cross validation. This results in more precisely tuned parameter 
# than depending on simple model accuracy scores, and is why the algorithm 
# is name Grid-Search-CV.

from sklearn import svm, grid_search, datasets
from time import time

iris = datasets.load_iris()
parameters = {'kernel': ('linear', 'rbf'), 'C': [1, 5, 10]}
model = svm.SVC()

# Utility function to report best scores
def report(grid_scores, n_top=3):
    from operator import itemgetter
    import numpy as np
    top_scores = sorted(grid_scores, key=itemgetter(1), reverse=True)[:n_top]
    for i, score in enumerate(top_scores):
        print("Model with rank: {0}".format(i + 1))
        print("Mean validation score: {0:.3f} (std: {1:.3f})".format(
              score.mean_validation_score,
              np.std(score.cv_validation_scores)))
        print("Parameters: {0}".format(score.parameters))
        print("")

classifier = grid_search.GridSearchCV(model, parameters)
start = time()
classifier.fit(iris.data, iris.target)

print("GridSearchCV took %.2f seconds for %d candidate parameter settings."
      % (time() - start, len(classifier.grid_scores_)))

report(classifier.grid_scores_)




# In addition to explicitly defining the parameters you want tested, you can also
# use randomized parameter optimization with SciKit-Learn's RandomizedSearchCV class.
# The semantics are a bit different here. First, instead of passing a list of 
# grid objects (with GridSearchCV, you can actually perform multiple grid 
# optimizations, consecutively), this time you pass in a your parameters as a 
# single dictionary that holds either possible, discrete parameter values or 
# distribution over them. SciPy's Statistics module have many such functions 
# you can use to create continuous, discrete, and multivariate type distributions, 
# such as expon, gamma, uniform, randin and many more:

import scipy 

parameter_dist = {
  'C': scipy.stats.expon(scale=100),
  'kernel': ['linear'],
  'gamma': scipy.stats.expon(scale=.1),
}

classifier = grid_search.RandomizedSearchCV(model, parameter_dist)
classifier.fit(iris.data, iris.target)
classifier.grid_scores_