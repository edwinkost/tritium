
import pandas as pd
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error

from sklearn.model_selection import KFold
from sklearn.model_selection import LeaveOneOut
from sklearn.model_selection import LeavePOut

from sklearn.model_selection import cross_val_score

# read dataset
# ~ dataset = pd.read_csv("../datasets/version_20230808/dataset_selected_20230808.csv", sep = ";")
# -- using the new dataset from Jaivime
dataset = pd.read_csv("../datasets/version_20230812/GeospatialModel_20230722.csv")
print(dataset.to_string())

# include pet_p_ratio and dwt_m as predictors
predictors = pd.DataFrame()
# ~ predictors["pet_p_ratio"] = dataset["pet_p_ratio"]
# ~ predictors["dwt_m"]       = dataset["dwt_m"]
# -- using the new dataset from Jaivime
# ~ No,Country,SiteID,SiteUniID,aet_p,pet_p,dwt,peak_v,cxtfit_v,cxtfit_D,cxtfit_R2,Applicability_tau
predictors["pet_p_ratio"] = dataset["pet_p"]
predictors["dwt_m"]       = dataset["dwt"]

# add a multiplicative term incorporating the above pre
# - calculate the average values of predictor variables
avg_pet_p_ratio = predictors["pet_p_ratio"].mean()
avg_dwt_m       = predictors["dwt_m"].mean()
# - using the centered values
multiplicative_term = (predictors["pet_p_ratio"] - avg_pet_p_ratio) * (predictors["dwt_m"] - avg_dwt_m)
predictors["multiplicative_term"] = multiplicative_term
# ~ print(multiplicative_term)

# target variables
# ~ target = dataset["Applicability_tau_yr"].astype(float)
# -- using the new dataset from Jaivime
# ~ No,Country,SiteID,SiteUniID,aet_p,pet_p,dwt,peak_v,cxtfit_v,cxtfit_D,cxtfit_R2,Applicability_tau
target = dataset["Applicability_tau"].astype(float)
# ~ print(target)

# fit the model using all data
mlr_model = LinearRegression()
mlr_model.fit(predictors, target)

# intercept and regression coefficients
print(mlr_model.intercept_)
print(mlr_model.coef_)
# ~ -17.82419356404767
# ~ [ 3.91379777  0.36500267 -0.08373464]

# calculate performance values
# - r squared and adj_r_squared
r_squared     = mlr_model.score(predictors, target)
adj_r_squared = 1 - (1-r_squared)*(len(target)-1)/(len(target)-predictors.shape[1]-1)
print(r_squared)
print(adj_r_squared)
# - rmse and mae
predictions = mlr_model.predict(predictors)
rmse        = (mean_squared_error(target, predictions))**0.5
mae         = mean_absolute_error(target, predictions)
print(rmse)
print(mae)


# cross validation - with LeavePOut
leaveout = LeavePOut(9)

# ~ # number of splits
# ~ print(leaveout.get_n_splits(predictors))

for train_index, test_index in leaveout.split(predictors): 
   # ~ print("TRAIN:", train_index, "TEST:", test_index)

   # train dataset
   predictors_train = pd.DataFrame()
   predictors_train["pet_p_ratio"]         = predictors["pet_p_ratio"][train_index]
   predictors_train["dwt_m"]               = predictors["dwt_m"][train_index]
   predictors_train["multiplicative_term"] = predictors["multiplicative_term"][train_index]
   
   print(predictors_train)

   
   # ~ X_train, X_test = X[train_index], X[test_index]
   # ~ Y_train, Y_test = Y[train_index], Y[test_index]



# ~ # cross validation - I don't trust this
# ~ lm = LinearRegression()
# ~ X_train = predictors
# ~ y_train = target
# ~ folds = KFold(n_splits = 5, shuffle = True, random_state = 100)
# ~ folds = KFold(n_splits = 5, shuffle = True)
# ~ folds = LeaveOneOut()
# ~ scores = cross_val_score(lm, X_train, y_train, scoring='neg_mean_absolute_error', cv=folds)
# ~ scores = cross_val_score(lm, X_train, y_train, scoring='neg_mean_absolute_error', cv=folds)
# ~ print(scores)   
# ~ print(scores.mean())   



