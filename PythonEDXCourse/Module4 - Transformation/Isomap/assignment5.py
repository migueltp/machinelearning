import pandas as pd

from scipy import misc
from mpl_toolkits.mplot3d import Axes3D
import matplotlib
import matplotlib.pyplot as plt
from sklearn import manifold
import os

# Look pretty...
matplotlib.style.use('ggplot')


#
# TODO: Start by creating a regular old, plain, "vanilla"
# python list. You can call it 'samples'.
#
samples = []
samples2 = []

#
# TODO: Write a for-loop that iterates over the images in the
# Module4/Datasets/ALOI/32/ folder, appending each of them to
# your list. Each .PNG image should first be loaded into a
# temporary NDArray, just as shown in the Feature
# Representation reading.
#
# Optional: Resample the image down by a factor of two if you
# have a slower computer. You can also convert the image from
# 0-255  to  0.0-1.0  if you'd like, but that will have no
# effect on the algorithm's results.
#
for i in os.listdir("Datasets/ALOI/32"):
    samples.append(misc.imread("Datasets/ALOI/32/{0}".format(i)))

for i in os.listdir("Datasets/ALOI/32i"):
    samples2.append(misc.imread("Datasets/ALOI/32i/{0}".format(i)))



#
# TODO: Once you're done answering the first three questions,
# right before you converted your list to a dataframe, add in
# additional code which also appends to your list the images
# in the Module4/Datasets/ALOI/32_i directory. Re-run your
# assignment and answer the final question below.
#
# .. your code here .. 


#
# TODO: Convert the list to a dataframe
#
df = pd.DataFrame()
df2 = pd.DataFrame()
for i in samples:
    df = df.append(pd.DataFrame(i))
df['colours'] = 'b'
for i in samples2:
    df2 = df2.append(pd.DataFrame(i))
df2['colours'] = 'r'
df = df.append(df2)
labels = df.colours
df = df.drop('colours', axis=1)
#
# TODO: Implement Isomap here. Reduce the dataframe df down
# to three components, using K=6 for your neighborhood size
#
iso = manifold.Isomap(n_neighbors=6, n_components=3)
iso.fit(df)
manifold = iso.transform(df)


#
# TODO: Create a 2D Scatter plot to graph your manifold. You
# can use either 'o' or '.' as your marker. Graph the first two
# isomap components
#
fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_title('2d Isomap')
ax.set_xlabel('Component 1')
ax.set_ylabel('Component 2')
ax.scatter(manifold[:,0], manifold[:,1], c=labels, marker='.', alpha=0.75)




#
# TODO: Create a 3D Scatter plot to graph your manifold. You
# can use either 'o' or '.' as your marker:
#
# .. your code here .. 



plt.show()
