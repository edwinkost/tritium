
import pandas as pd
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

from sklearn.model_selection import KFold
from sklearn.model_selection import LeaveOneOut
from sklearn.model_selection import LeavePOut

from sklearn.model_selection import cross_val_score


# calculate performance values
def calculate_performance(predictors, target, model):

    predictions = model.predict(predictors)
    
    # - r squared and adj_r_squared
    r_squared     = r2_score(target, predictions)
    adj_r_squared = 1 - (1-r_squared)*(len(target)-1)/(len(target)-predictors.shape[1]-1)
    # ~ print(r_squared)
    # ~ print(adj_r_squared)
    # - rmse and mae
    rmse        = (mean_squared_error(target, predictions))**0.5
    mae         = mean_absolute_error(target, predictions)
    # ~ print(rmse)
    # ~ print(mae)
    
    return r_squared, adj_r_squared, rmse, mae 

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
intr_all = mlr_model.intercept_
coef_all = mlr_model.coef_

# get performance values
r_squared_all, adj_r_squared_all, rmse_all, mae_all = calculate_performance(predictors, target, mlr_model)    



# cross validation - with LeavePOut
leaveout = LeavePOut(10)

# make splits
leaveout.get_n_splits(predictors)

# use 50,000 samples only
i = 0

for train_index, test_index in leaveout.split(predictors): 

   i = i + 1
   print(i)

   # ~ print("TRAIN:", train_index, "TEST:", test_index)

   # train dataset
   predictors_train = pd.DataFrame()
   predictors_train["pet_p_ratio"]         = predictors["pet_p_ratio"][train_index]
   predictors_train["dwt_m"]               = predictors["dwt_m"][train_index]
   predictors_train["multiplicative_term"] = predictors["multiplicative_term"][train_index]
   target_train                            = target[train_index]               
   
   # test dataset
   predictors_test = pd.DataFrame()
   predictors_test["pet_p_ratio"]          = predictors["pet_p_ratio"][test_index]
   predictors_test["dwt_m"]                = predictors["dwt_m"][test_index]
   predictors_test["multiplicative_term"]  = predictors["multiplicative_term"][test_index]
   target_test                             = target[test_index]               

   # fit the model using the train dataset
   mlr_model_train = LinearRegression()
   mlr_model_train.fit(predictors_train, target_train)
   intr_train = mlr_model.intercept_
   coef_train = mlr_model.coef_

   # get the performance based on the train data
   r_squared_train, adj_r_squared_train, rmse_train, mae_train = calculate_performance(predictors_train, target_train, mlr_model_train)
   print(r_squared_train, adj_r_squared_train, rmse_train, mae_train)    

   # get the performance based on the test data
   r_squared_test, adj_r_squared_test, rmse_test, mae_test = calculate_performance(predictors_test, target_test, mlr_model_train)    
   print(r_squared_test, adj_r_squared_test, rmse_test, mae_test)    
   
   if i == 50: break
    
   
   

   
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



