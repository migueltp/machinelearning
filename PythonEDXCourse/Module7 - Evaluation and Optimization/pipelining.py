# -*- coding: utf-8 -*-


# SciKit-Learn has created a pipelining class. It wraps around your entire 
# data analysis pipeline from start to finish, and allows you to interact with 
# the pipeline as if it were a single white-box, configurable estimator. 

# The other added benefit is that once your pipeline has been built, since the 
# pipeline inherits from the estimator base class, you can use it pretty much 
# anywhere you'd use regular estimators—including in your cross validator method. 
# Doing so, you can simultaneously fine tune the parameters of each of the 
# estimators and predictors that comprise your data-analysis pipeline.




# If you don't want to encounter errors, there are a few rules you must abide by 
# while using SciKit-Learn's pipeline:
# 
# - Every intermediary model, or step within the pipeline must be a transformer. 
#   That means its class must implement both the .fit() and the .transform() methods. 
#   This is rather important, as the output from each step will serve as the 
#   input to the subsequent step! 
# 
# Every algorithm you've learned about in this class implements .fit() so you're good there, 
# but not all of them implement .transform(). 
# Be sure to take a look at the SciKit-Learn documentation for each algorithm to 
# learn if it qualifier as a transformer, and make note of that on your course map.
# 
# - The very last step in your analysis pipeline only needs to implement 
#   the .fit() method, since it will not be feeding data into another step



from sklearn.pipeline import Pipeline
from sklearn import svm, grid_search, datasets
from sklearn.decomposition import RandomizedPCA
from sklearn.cross_validation import train_test_split

svc = svm.SVC(kernel='linear')
pca = RandomizedPCA()

pipeline = Pipeline([
  ('pca', pca),
  ('svc', svc)
])
pipeline.set_params(pca__n_components=3, svc__C=1, svc__gamma=0.0001)

# some data
iris = datasets.load_iris()
X = iris.data[:, :2]  # we only take the first two features.
y = iris.target

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=0)


pipeline.fit(X, y)
pipeline.score(X_test, y_test)



# Many of the predictors you learned about in the last few chapters don't actually 
# implement .transform()! Due to this, by default, you won't be able to use SVC, 
# Linear Regression, or Decision Trees, etc. as intermediary steps within your pipeline. 

# A very nifty hack you should be aware of to circumvent this is by writing your 
# own transformer class, which simply wraps a predictor and masks it as a transformer:# 

from sklearn.base import TransformerMixin

class ModelTransformer(TransformerMixin):

  def __init__(self, model):
    self.model = model

  def fit(self, *args, **kwargs):
    self.model.fit(*args, **kwargs)
    return self

  def transform(self, X, **transform_params):
    # This is the magic =)
    return DataFrame(self.model.predict(X))