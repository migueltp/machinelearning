import matplotlib as mpl
import matplotlib.pyplot as plt
from sklearn.cross_validation import train_test_split
from sklearn.svm import SVC
from sklearn import preprocessing
from sklearn.neighbors import KNeighborsClassifier
import pandas as pd
import numpy as np 
import time



# Load up the /Module6/Datasets/parkinsons.data data set into a variable X
# being sure to drop the name column.
X = pd.read_csv("Datasets/parkinsons.data")


# Splice out the status column into a variable y and delete it from X.
y = X.status
X = X.drop('name', axis=1)
X = X.drop('status', axis=1)


# Perform a train/test split. 30% test group size, with a random_state equal to 7.
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, 
                                                    random_state=7)
                                                    


# Create a SVC classifier. Don't specify any parameters, 
# just leave everything as default. Fit it against your training data and then
# score your testing data.

model = SVC()
model.fit(X_train, y_train)
score = model.score(X_test, y_test)

# Program a naive, best-parameter searcher by creating a nested for-loops. 
# The outer for-loop should iterate a variable C from 0.05 to 2, using 0.05 unit increments. 
# The inner for-loop should increment a variable gamma from 0.001 to 0.1, 
# using 0.001 unit increments.
# As you know, Python ranges won't allow for float intervals, so you'll have to
# do some research on NumPy ARanges, if you don't already know how to use them.

res = pd.DataFrame(columns=['score','C','gamma'])                            

for C in np.arange(0.05,2,0.05):
    
    for G in np.arange(0.001, 0.1, 0.001):
        
        model = SVC(C=C, gamma=G, kernel='rbf')
        model.fit(X_train, y_train)
        score = model.score(X_test, y_test)
        print "Score:\n", score
        res = res.append({'score':score,
                      'C':C,
                      'gamma':G},
                      ignore_index=True)

res.max()        


# Inject SciKit-Learn pre-processing code

X = pd.read_csv("Datasets/parkinsons.data")
y = X.status
X = X.drop('name', axis=1)
X = X.drop('status', axis=1)
X = preprocessing.StandardScaler().fit_transform(X)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, 
                                                    random_state=7)
                                                    

#T = preprocessing.MinMaxScaler().fit_transform(df)
#T = preprocessing.normalize(df)
#T = preprocessing.scale(X)

res = pd.DataFrame(columns=['score','C','gamma'])                            

for C in np.arange(0.05,2,0.05):
    
    for G in np.arange(0.001, 0.1, 0.001):
        
        model = SVC(C=C, gamma=G, kernel='rbf')
        model.fit(X_train, y_train)
        score = model.score(X_test, y_test)
        print "Score:\n", score
        res = res.append({'score':score,
                      'C':C,
                      'gamma':G},
                      ignore_index=True)

res.max()        