# -*- coding: utf-8 -*-
"""
@author: miguelserrano
"""

import pandas as pd


def transform_data(trainData):

    y = trainData.pivot_table(index=['Agencia_ID',
                                     'Canal_ID',
                                     'Ruta_SAK',
                                     'Cliente_ID',
                                     'Producto_ID'],
                              values=['Venta_uni_hoy', 'Dev_uni_proxima'],
                              columns='Semana', fill_value=0)

    X = pd.DataFrame({'Agencia_ID': y.index.get_level_values(0),
                      'Canal_ID': y.index.get_level_values(1),
                      'Ruta_SAK': y.index.get_level_values(2),
                      'Cliente_ID': y.index.get_level_values(3),
                      'Producto_ID': y.index.get_level_values(4)}
                     )

    vals = list(y.columns.get_level_values(1).unique())

    for i in vals:

        pos = vals.index(i)
        new_dem = 'demand_wk_' + str(i)
        new_ret = 'retuns_wk_' + str(i)
        X[new_dem] = list(y.Venta_uni_hoy.iloc[:, pos])
        X[new_ret] = list(y.Dev_uni_proxima.iloc[:, pos])

    return X


def join_clean_product(path, train_data):

    products = pd.read_csv(path)

    # Get weight,volume and pieces (always expressed in the same units :))
    products['weight'] = products['NombreProducto'].str.extract(r''
                                    '(\d+\s?((?=kg|Kg|g|G)))', expand=False)[0]

    products['volume'] = products['NombreProducto'].str.extract(r'(\d+(?=ml))',
                                                                expand=False)

    products['pieces'] = products['NombreProducto'].str.extract(r''
                                        '(\s?\d+(?=(p|P)))',  expand=False)[0]

    prod_split = products.NombreProducto.str.split(r''
    "(\s\d+\s?(kg|Kg|g|G|in|ml|pct|p|P|Reb))")

    products['product'] = prod_split.apply(lambda x: x[0])
    products['brand'] = prod_split.apply(lambda x:
                                    x[-1]).str.split().apply(lambda x:
                                                             x[:-1])
    products['num_brands'] = products.brand.apply(lambda x: len(x))
    products['prod_split'] = products['product'].str.split(r''
                                            '[A-Z][A-Z]').apply(lambda x: x[0])

    products.fillna(value=-9, axis=0, inplace=True)

    products[['weight',
              'volume',
              'pieces']] = products[['weight',
                                     'volume',
                                     'pieces']].apply(pd.to_numeric)

    products = products[['Producto_ID', 'brand', 'prod_split', 'num_brands',
                         'weight', 'volume', 'pieces']]

    data = pd.merge(left=train_data, right=products, on='Producto_ID')

    return products, data
