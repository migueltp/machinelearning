import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
from mpl_toolkits.mplot3d import Axes3D

# Look pretty...
matplotlib.style.use('ggplot')


#
# TODO: Load up the Seeds Dataset into a Dataframe
# It's located at 'Datasets/wheat.data'
#
df = pd.read_csv("../Datasets/wheat.data")



fig = plt.figure()
#
# TODO: Create a new 3D subplot using fig. Then use the
# subplot to graph a 3D scatter plot using the area,
# perimeter and asymmetry features. Be sure to use the
# optional display parameter c='red', and also label your
# axes
#
ax = fig.add_subplot(111, projection='3d')
ax.set_zlabel('perimeter')
ax.set_ylabel('asymmetry')
ax.set_xlabel('area')

ax.scatter(df.area, df.asymmetry, df.perimeter, c='r', marker='.')



fig = plt.figure()
#
# TODO: Create a new 3D subplot using fig. Then use the
# subplot to graph a 3D scatter plot using the width,
# groove and length features. Be sure to use the
# optional display parameter c='green', and also label your
# axes
#
az = fig.add_subplot(111, projection='3d')
az.set_zlabel('width')
az.set_ylabel('groove')
az.set_xlabel('length')

az.scatter(df.width, df.groove, df.length, c='r', marker='.')



plt.show()
