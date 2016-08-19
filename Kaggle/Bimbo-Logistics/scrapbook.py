# -*- coding: utf-8 -*-
"""
@author: miguelserrano
"""






# Join Pred with Test
X_test = pd.concat([X_test.reset_index(drop=True),
                    pd.Series(y_pred, name='pred'),
                    y_test.reset_index(drop=True)], axis=1)

X_test['diff_pred'] = abs(X_test.pred - X_test.demand_wk_9)
X_test.diff_pred.mean()
