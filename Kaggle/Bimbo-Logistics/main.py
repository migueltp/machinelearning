import pandas as pd
import sklearn.metrics as metrics
from sklearn.cross_validation import train_test_split
from sklearn.tree import DecisionTreeRegressor
from time import time

from preprocessing import transform_train_data, join_clean_product, transform_test_data
from helpers import runModel, submission


### Config
first_run = False


### Read Data

if first_run:

    p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/train.csv'
    print 'Reading Data ...'
    start = time()
    train = pd.read_csv(p)
    print("Data took %.2f seconds to Read" % (time() - start))

    ### Data Management
    print 'Writing Partitions to Disk ...'

    start = time()
    for i in train.Agencia_ID.unique():
        print 'Subsetting & Writing Agencia', i
        p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/' \
            'Agencies/{0}_agencia_train.csv'.format(i)
        train.query('Agencia_ID == {0}'.format(i)).to_csv(p, index=False)
        print 'Done with ', i

    ###
    # SAMPLE DOWNSIZED TO AGENCY 1911
    train = train.loc[train.Agencia_ID == 1911, ]
    ###
    print("Data Partition/Write took %.2f seconds" % (time() - start))

else:

    p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/' \
        'Data/Agencies/1911_agencia_train.csv'
    train = pd.read_csv(p)


### Preprocess
# TODO: Clustering
# 1- Agency clustering: agencies that sell similar qt of product types
# 2- Product Clustering: group similar products (brand, nr_pieces, qtty sold)
# 3- Client Clustering: group similar product type, brand, qtty
# 4- Append those clusters info into the train and test dataframes.

# Transform training data by exploding columnns [demand, return] by week nr
print 'Transforming training Data ...'
start = time()
train = transform_train_data(trainData=train)
print("Training Data took %.2f seconds to Transform" % (time() - start))

# Cities
# TODO: City contain info that can help relate agencies into areas
#p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/' \
#    'town_state.csv'
#cities = pd.read_csv(p)

# Products
p = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/' \
    'producto_tabla.csv'

print 'Transforming Product Data and Joining...'
start = time()
products, train = join_clean_product(path=p, train_data=train)
print("Transf/Join Product Data took %.2f seconds" % (time() - start))

# Attributes must be numerical...
# TODO: Find a faster way to categorize lists within data frame
print 'Transforming Nominal Vars to Numerical ...'
start = time()
brand = train.brand.apply(lambda x: pd.Series(x[0]))
brand = pd.get_dummies(brand)
train = pd.concat([train, brand], axis=1)
print("Nominal Vars to Numerical took %.2f seconds" % (time() - start))

# This way is MUCH FASTER
train = pd.concat([train, pd.get_dummies(train.prod_split)], axis=1)

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
# TODO: Fit a boosting regressor
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

print "Mean Absl. Err:  Mean Sqr Err: \t R2:\n", mae, '\t', mse, '\t', r2_score
print("Model took %.2f seconds to score" % (time() - start))


### Submission
# TODO:
# 1- Transform test data into usable format to Model
# 2- Write Submission Function
# 3- Have fun with it!
r = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/test.csv'
w = '/home/miguelserrano/Projects/Data/Kaggle/BimboLogistics/Data/test_trf.csv'

test = transform_test_data(read_path=r, trainData=train, write_path=w)
