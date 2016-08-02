import pandas as pd
import numpy as np


# TODO:
# Load up the dataset, setting correct header labels
# Use basic pandas commands to look through the dataset...
# get a feel for it before proceeding!
# Find out what value the dataset creators used to
# represent "nan" and ensure it's properly encoded as np.nan
#
df = pd.read_csv('../Datasets/census.data', names=[
    'education', 'age', 'capital-gain', 'race', 'capital-loss', 'hours-per-week', 'sex', 'classification'
    ])

len(df.columns)
pd.value_counts(df.education)         


# TODO:
# Figure out which features should be continuous + numeric
# Conert these to the appropriate data type as needed,
# that is, float64 or int64
#
df.dtypes


# TODO:
# Look through your data and identify any potential categorical
# features. Ensure you properly encode any ordinal types using
# the method discussed in the chapter.
#
ordinal_features = ['Preschool','1st-4th','5th-6th','Doctorate','12th','9th','7th-8th','10th','11th',
                    'Masters','Bachelors','Some-college','HS-grad'
                    ]
df.education = df.education.astype("category",
                                 ordered=True,
                                 categories=ordinal_features).cat.codes


# TODO:
# Look through your data and identify any potential categorical
# features. Ensure you properly encode any nominal types by
# exploding them out to new, separate, boolean fatures.
#
df = pd.get_dummies(df,columns=['race'])
df = pd.get_dummies(df,columns=['sex'])
df = pd.get_dummies(df,columns=['classification'])



# TODO:
# Print out your dataframe
len(df.columns)