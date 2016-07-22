import math
import csv
import os
import pandas as pd


def evaluate_res(dataset, pred_var, real_var):

    p = [math.log(x + 1) for x in dataset[pred_var]]
    a = [math.log(x + 1) for x in dataset[real_var]]
    error = sum([math.pow(x - y, 2) for x, y in zip(p, a)])
    error = math.sqrt(error) / len(dataset)
    print error


print os.listdir("./Data/")
train_data = pd.read_csv("./Data/train.csv", nrows=10000)
test_data = pd.read_csv("./Data/test.csv", nrows=10000)
clients = pd.read_csv("./Data/cliente_tabla.csv")
town = pd.read_csv("./Data/town_state.csv")
products = pd.read_csv("./Data/producto_tabla.csv")

# Sort by Cols
test_data.sort_values(['Agencia_ID','Canal_ID'])

# Count distinct by Col

print test_data.groupby('Agencia_ID').Agencia_ID.nunique()
## evaluate_res(dataset=train_data, pred_var='Demanda_uni_equil', real_var='Demanda_uni_equil')
