from time import time
import numpy as np
import pandas as pd
from preprocessing import transform_data, join_clean_product
from sklearn.cross_validation import train_test_split
from sklearn.tree import DecisionTreeRegressor
import sklearn.metrics as metrics
from helpers import runModel, report


### Read Data
#p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/train.csv'
#train = train.loc[x.Agencia_ID == 1110, ]

#train.to_csv('/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/'
#             'train_agencia_1110.csv', index=False)

p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/' \
    'train_agencia_1110.csv'
train = pd.read_csv(p)


### Preprocess

# Transform training data by exploding columnns [demand, return] by week nr
train = transform_data(trainData=train)

# Cities
p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/' \
    'town_state.csv'
cities = pd.read_csv(p)

# Products
p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/' \
    'producto_tabla.csv'

products, train = join_clean_product(path=p, train_data=train)


# Attributes must be numerical...
brand = train.brand.apply(lambda x: pd.Series(x[0]))
brand = pd.get_dummies(brand)
train = pd.concat([train, brand], axis=1)

# Drop unused columns
train.drop(['Agencia_ID', 'brand', 'prod_split'], axis=1, inplace=True)


# Label = Latest week demand
train_y = train.demand_wk_9
train = train.drop('demand_wk_9', axis=1)

### Split Data
X_train, X_test, y_train, y_test = train_test_split(train,
                                                    train_y,
                                                    test_size=0.3,
                                                    random_state=7)

### Model
model = DecisionTreeRegressor(criterion="mse", splitter="best", max_depth=None,
                              random_state=7)

model = runModel(model=model, trainX=X_train, trainY=y_train,
                 optimize=False, parameters=0, scoring='mean_squared_error')

print "Applying Model ..."
start = time()
y_pred = model.predict(X_test)
print("Model took %.2f seconds to predict vals" % (time() - start))


### Evaluation
print "Scoring Classifier..."

start = time()
mae = metrics.mean_absolute_error(y_test, y_pred)
mse = metrics.mean_squared_error(y_test, y_pred)
r2_score = metrics.r2_score(y_test, y_pred)

print "Mean Absl. Err:  Mean Avg Err: \t R2:\n", mae, '\t', mse, '\t', r2_score
print("Model took %.2f seconds to score" % (time() - start))
