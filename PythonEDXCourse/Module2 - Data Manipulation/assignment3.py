import pandas as pd

# TODO: Load up the dataset
# Ensuring you set the appropriate header column names
#
df = pd.read_csv("../Datasets/servo.data",
                 names=['motor',
                        'screw',
                        'pgain',
                        'vgain',
                        'class'])

# TODO: Create a slice that contains all entries
# having a vgain equal to 5. Then print the 
# length of (# of samples in) that slice:
#
df_slice = df[df.vgain == 5]
len(df_slice)

# TODO: Create a slice that contains all entries
# having a motor equal to E and screw equal
# to E. Then print the length of (# of
# samples in) that slice:
#
df_slice = df[(df.motor == 'E') & (df.screw == 'E')]
print len(df_slice)



# TODO: Create a slice that contains all entries
# having a pgain equal to 4. Use one of the
# various methods of finding the mean vgain
# value for the samples in that slice. Once
# you've found it, print it:
#
df_slice = df[df.pgain == 4]
print df_slice.vgain.mean()



# TODO: (Bonus) See what happens when you run
# the .dtypes method on your dataframe!
print df
df.dtypes


