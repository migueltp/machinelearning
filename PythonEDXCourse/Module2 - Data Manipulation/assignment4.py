import pandas as pd


# TODO: Load up the table, and extract the dataset
# out of it. If you're having issues with this, look
# carefully at the sample code provided in the reading
#
df = pd.read_html(io='http://espn.go.com/nhl/statistics/player/_/stat/points/sort/points/year/2015/seasontype/2',
                  header=1)[0]


# TODO: Rename the columns so that they match the
# column definitions provided to you on the website
#


# TODO: Get rid of any row that has at least 4 NANs in it
#
df = df.dropna(axis=0, thresh=4)


# TODO: At this point, look through your dataset by printing
# it. There probably still are some erroneous rows in there.
# What indexing command(s) can you use to select all rows
# EXCEPT those rows?
#
df = df[df.PLAYER != 'PLAYER']


# TODO: Get rid of the 'RK' column
#
# .. your code here ..
df = df.drop('RK', axis=1)

# TODO: Ensure there are no holes in your index by resetting
# it. By the way, don't store the original index
#
df = df.reset_index(drop=True)



# TODO: Check the data type of all columns, and ensure those
# that should be numeric are numeric
# df = df.convert_objects(convert_numeric=True)
df = df.apply(pd.to_numeric, errors='ignore')
df.dtypes


# TODO: Your dataframe is now ready! Use the appropriate 
# commands to answer the questions on the course lab page.
len(list(df['PCT'].unique()))
sum(df.loc[15:16,'GP'])

