# -*- coding: utf-8 -*-

from sklearn.cross_validation import train_test_split

data = [0,1,2,3,4,5,6,7,8,9]  # input dataframe samples
labels = [0,0,0,0,0,1,1,1,1,1]  # the function we're training is " >4 "

data_train, data_test, label_train, label_test = train_test_split(data, labels, test_size=0.5, random_state=7)

data_train
[9, 7, 3, 6, 4]

label_train
[1, 1, 0, 1, 0]

data_test
[8, 5, 0, 2, 1]

label_test
[1, 1, 0, 0, 0]
