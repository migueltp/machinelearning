import pandas as pd
import matplotlib.pyplot as plt
import matplotlib

# Look pretty...
matplotlib.style.use('ggplot')

#
# TODO: Load up the Seeds Dataset into a Dataframe
# It's located at 'Datasets/wheat.data'
#
df = pd.read_csv("../Datasets/wheat.data")


#
# TODO: Create a slice of your dataframe (call it s1)
# that only includes the 'area' and 'perimeter' features
#
s1 = df[['area','perimeter']]


#
# TODO: Create another slice of your dataframe (call it s2)
# that only includes the 'groove' and 'asymmetry' features
#
s2 = df[['groove','asymmetry']]



# TODO: Create a histogram plot using the first slice,
# and another histogram plot using the second slice.
# Be sure to set alpha=0.75
#
s1.plot.hist(alpha=0.75)
s2.plot.hist(alpha=0.75)

plt.show()
plt.close()