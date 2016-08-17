from sklearn.metrics import roc_curve, auc
import matplotlib.pyplot as plt
import random

actual = [1,1,1,0,0,0]
predictions = [0.9,0.9,0.9,0.1,0.1,0.1]

false_positive_rate, true_positive_rate, thresholds = roc_curve(actual, predictions)
roc_auc = auc(false_positive_rate, true_positive_rate)

plt.title('Receiver Operating Characteristic')
plt.plot(false_positive_rate, true_positive_rate, 'b',
label='AUC = %0.2f'% roc_auc)
plt.legend(loc='lower right')
plt.plot([0,1],[0,1],'r--')
plt.xlim([-0.1,1.2])
plt.ylim([-0.1,1.2])
plt.ylabel('True Positive Rate')
plt.xlabel('False Positive Rate')
plt.show()



###
### MODEL EXPERIMENTS
###

# SVM as first approach
g = 0.01
c = 10
model = SVC(C=c, gamma=g, kernel='rbf',
            class_weight='balanced',
            probability=True)


model = runModel(model=model, X_train=X_train[0:20000],
                 y_train=y_train[0:20000], optimize=False, parameters=0,
                 scoring='roc_auc')


# SVM with Parameter Optimization
parameters = {'kernel': ['rbf'], 'C': [5, 10, 25], 'gamma': [0.1, 0.01, 0.001]}

model = SVC(class_weight='balanced', probability=True)
model = runModel(model=model, trainX=X_train[0:1000], trainY=y_train[0:1000],
                 optimize=True, parameters=parameters, scoring='roc_auc')


# Rand Forest with Parameter Optimization
parameters = {'n_estimators': [50, 100, 200], 'max_depth': [10, 25],
              'min_samples_leaf': [2, 5, 10], 'oob_score': [True, False]}

model = RandomForestClassifier(random_state=7, class_weight='balanced')
model = runModel(model=model, trainX=X_train[0:1000], trainY=y_train[0:1000],
                 optimize=True, parameters=parameters, scoring='roc_auc')
                 
# Gradient Boosting - Problems with:
# Unable to set loss function to AUC or Recall @ positive class
# This leads to boosting towards a global score, which is not desired!
model = GradientBoostingClassifier(loss='deviance', learning_rate=0.3,
                                        n_estimators=200, max_depth=7,
                                        min_samples_leaf=10, random_state=7,
                                        max_features=None, verbose=1)

model = runModel(model=model, trainX=X_train, trainY=y_train,
                 optimize=False, parameters=parameters, scoring='roc_auc')