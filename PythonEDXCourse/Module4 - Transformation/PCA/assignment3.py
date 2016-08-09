import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import assignment2_helper as helper
from sklearn.decomposition import PCA


# Look pretty...
matplotlib.style.use('ggplot')


# Do * NOT * alter this line, until instructed!
scaleFeatures = True


# TODO: Load up the dataset and remove any and all
# Rows that have a nan. You should be a pro at this
# by now ;-)
df = pd.read_csv("Datasets/kidney_disease.csv")
df.isnull()
df = df.drop(['id', 'rbc', 'pc', 'pcc', 'ba', 'htn', 'dm', 'cad', 'appet', 'pe', 'ane'],
        axis=1)
df = df.dropna(axis=0)

# Create some color coded labels; the actual label feature
# will be removed prior to executing PCA, since it's unsupervised.
# You're only labeling by color so you can see the effects of PCA
labels = ['red' if i=='ckd' else 'green' for i in df.classification]
sub = df.drop('classification', axis=1)



# TODO: Print out and check your dataframe's dtypes. You'll probably
# want to call 'exit()' after you print it out so you can stop the
# program's execution.
#
# You can either take a look at the dataset webpage in the attribute info
# section: https://archive.ics.uci.edu/ml/datasets/Chronic_Kidney_Disease
# or you can actually peek through the dataframe by printing a few rows.
# What kind of data type should these three columns be? If Pandas didn't
# properly detect and convert them to that data type for you, then use
# an appropriate command to coerce these features into the right type.
#
sub.dtypes
sub['wc'] = sub.wc.astype(int)
sub['rc'] = sub.rc.astype(float)
sub['pcv'] = sub.rc.astype(int)
sub.dtypes


# TODO: PCA Operates based on variance. The variable with the greatest
# variance will dominate. Go ahead and peek into your data using a
# command that will check the variance of every feature in your dataset.
# Print out the results. Also print out the results of running .describe
# on your dataset.
#
# Hint: If you don't see all three variables: 'bgr','wc' and 'rc', then
# you probably didn't complete the previous step properly.
#
for i in sub.columns:
    print [i,sub[i].var()]
    # print sub.i.var

sub.describe()

# TODO: This method assumes your dataframe is called df. If it isn't,
# make the appropriate changes. Don't alter the code in scaleFeatures()
# just yet though!
#
# .. your code adjustment here ..
if scaleFeatures: sub = helper.scaleFeatures(sub)



# TODO: Run PCA on your dataset and reduce it to 2 components
# Ensure your PCA instance is saved in a variable called 'pca',
# and that the results of your transformation are saved in 'T'.
#
pca = PCA(n_components=2)
pca.fit(sub)
PCA(copy=True, whiten=False)
T = pca.transform(sub)

# Plot the transformed data as a scatter plot. Recall that transforming
# the data will result in a NumPy NDArray. You can either use MatPlotLib
# to graph it directly, or you can convert it to DataFrame and have pandas
# do it for you.
#
# Since we've already demonstrated how to plot directly with MatPlotLib in
# Module4/assignment1.py, this time we'll convert to a Pandas Dataframe.
#
# Since we transformed via PCA, we no longer have column names. We know we
# are in P.C. space, so we'll just define the coordinates accordingly:
ax = helper.drawVectors(T, pca.components_, sub.columns.values, plt, scaleFeatures)
T = pd.DataFrame(T)
T.columns = ['component1', 'component2']
T.plot.scatter(x='component1', y='component2', marker='o', c=labels, alpha=0.75, ax=ax)




# BINARY PCA
df = pd.read_csv("Datasets/kidney_disease.csv")
df.isnull()
df = df.dropna(axis=0)
# Create some color coded labels; the actual label feature
# will be removed prior to executing PCA, since it's unsupervised.
# You're only labeling by color so you can see the effects of PCA
labels = ['red' if i=='ckd' else 'green' for i in df.classification]
sub2 = df.drop(['id', 'classification'],axis=1)
pd.get_dummies(sub2)











plt.show()


