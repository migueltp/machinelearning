# -*- coding: utf-8 -*-
import math
import pandas as pd
from time import time
from sklearn import preprocessing


def drawVectors(transformed_features, components_, columns, plt):

    num_columns = len(columns)

    # This funtion will project your *original* feature (columns)
    # onto your principal component feature-space, so that you can
    # visualize how "important" each one was in the
    # multi-dimensional scaling

    # Scale the principal components by the max value in
    # the transformed set belonging to that component
    xvector = components_[0] * max(transformed_features[:, 0])
    yvector = components_[1] * max(transformed_features[:, 1])

    ## visualize projections

    # Sort each column by it's length. These are your *original*
    # columns, not the principal components.
    important_features = {columns[i]: math.sqrt(xvector[i]**2 +
        yvector[i]**2) for i in range(num_columns)}
    important_features = sorted(zip(important_features.values(),
                                    important_features.keys()), reverse=True)
    print "Features by importance:\n", important_features

    ax = plt.axes()

    for i in range(num_columns):
        # Use an arrow to project each original feature as a
        # labeled vector on your principal component axes
        plt.arrow(0, 0, xvector[i], yvector[i], color='b', width=0.0005,
                  head_width=0.02, alpha=0.75)
        plt.text(xvector[i]*1.2, yvector[i]*1.2, list(columns)[i], color='b',
                 alpha=0.75)

    return ax


# Utility function to report best scores
def report(grid_scores, n_top):
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


# Run Model
def runModel(model, trainX, trainY, optimize, parameters, scoring):

    from time import time
    from sklearn import grid_search

    print 'Model Optimization =', optimize

    if optimize:

        classifier = grid_search.GridSearchCV(model, parameters, n_jobs=3,
                                              refit=True, scoring=scoring)

        print "Fitting Model & Optizing Parameters..."
        start = time()
        classifier.fit(trainX, trainY)
        print("GridSearchCV took %.2f seconds for %d "
              "candidate parameter settings."
              % (time() - start, len(classifier.grid_scores_)))
        report(classifier.grid_scores_, n_top=5)
        model = classifier.best_estimator_

    else:

        print "Fitting Model..."
        start = time()
        model.fit(trainX, trainY)
        print("Model took %.2f seconds to fit" % (time() - start))

    return model


# Submission
def submission(read_path, model, write_path):

    print "Reading testing file from path: \n{0}".format(read_path)
    test = pd.read_csv(read_path)

    test['has_dependents'] = 0
    test.loc[test.NumberOfDependents != 0, 'has_dependents'] = 1
    test['late_90_days'] = 0
    test.loc[test.NumberOfTimes90DaysLate != 0, 'late_90_days'] = 1
    test['income_per_capita'] = test.MonthlyIncome
    val = test.MonthlyIncome/test.NumberOfDependents
    test.loc[test.NumberOfDependents > 0, 'income_per_capita'] = val
    test = test.drop(['Unnamed: 0', 'SeriousDlqin2yrs'], axis=1)
    test = test.fillna(test.mean())
    scaled = preprocessing.scale(test)

    test = pd.DataFrame(scaled, columns=test.columns)

    # Apply Prediction
    print "Applying Model ..."
    start = time()
    y_pred = model.predict_proba(test)
    y_vals = model.predict(test)
    print("Model took %.2f seconds to apply" % (time() - start))

    # Write csv
    sub = pd.DataFrame(y_pred[:, 1], columns=['Probability'])
    sub['Id'] = range(1, 101504, 1)
    sub = sub[['Id', 'Probability']]
    sub.to_csv(write_path, sep=',', index=False)
    print 'Sample ready for Submission, GL!'
