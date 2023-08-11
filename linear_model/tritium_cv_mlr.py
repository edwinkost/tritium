
import pandas as pd
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error

from sklearn.model_selection import KFold
from sklearn.model_selection import LeaveOneOut

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
avg_pet_p_ratio = dataset["pet_p_ratio"].mean()
avg_dwt_m       = dataset["dwt_m"].mean()
# - using the centered values
multiplicative_term = (dataset["pet_p_ratio"] - avg_pet_p_ratio) * (dataset["dwt_m"] - avg_dwt_m)
predictors["multiplicative_term"] = multiplicative_term
# ~ print(multiplicative_term)

# target variable
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
# ~ -13.130654161539773
# ~ [ 2.66284398  0.41955129 -0.09452936]

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

# cross validation - I don't trust this
lm = LinearRegression()
X_train = predictors
y_train = target
# ~ folds = KFold(n_splits = 5, shuffle = True, random_state = 100)
# ~ folds = KFold(n_splits = 5, shuffle = True)
folds = LeaveOneOut()
# ~ scores = cross_val_score(lm, X_train, y_train, scoring='neg_mean_absolute_error', cv=folds)
scores = cross_val_score(lm, X_train, y_train, scoring='neg_mean_absolute_error', cv=folds)
print(scores)   
print(scores.mean())   

# ~ sklearn.utils._param_validation.InvalidParameterError: The 'scoring' parameter of check_scoring must be a str among {'f1_samples', 'completeness_score', 'f1_weighted', 'balanced_accuracy', 'precision_macro', 'jaccard_weighted', 'neg_mean_squared_log_error', 'average_precision', 'rand_score', 'roc_auc_ovr', 'top_k_accuracy', 'accuracy', 'jaccard_samples', 'matthews_corrcoef', 'positive_likelihood_ratio', 'neg_mean_absolute_error', 'adjusted_mutual_info_score', 'recall_macro', 'recall_samples', 'roc_auc_ovo_weighted', 'jaccard_micro', 'explained_variance', 'adjusted_rand_score', 'neg_mean_absolute_percentage_error', 'f1_micro', 'neg_root_mean_squared_error', 'precision_micro', 'jaccard_macro', 'fowlkes_mallows_score', 'recall_micro', 'f1_macro', 'r2', 'roc_auc_ovr_weighted', 'recall_weighted', 'neg_log_loss', 'v_measure_score', 'precision', 'homogeneity_score', 'max_error', 'neg_mean_squared_error', 'precision_samples', 'normalized_mutual_info_score', 'precision_weighted', 'f1', 'recall', 'neg_mean_poisson_deviance', 'jaccard', 'roc_auc_ovo', 'neg_median_absolute_error', 'neg_negative_likelihood_ratio', 'roc_auc', 'neg_mean_gamma_deviance', 'neg_brier_score', 'mutual_info_score'}, a callable or None. Got 'mae' instead.
# ~ (sklearn_etc)
