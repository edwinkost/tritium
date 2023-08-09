
import pandas as pd
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error

# read dataset
dataset = pd.read_csv("../datasets/version_20230808/dataset_selected_20230808.csv", sep = ";")
# ~ print(dataset.to_string())

# include pet_p_ratio and dwt_m as predictors
predictors = pd.DataFrame()
predictors["pet_p_ratio"] = dataset["pet_p_ratio"]
predictors["dwt_m"]       = dataset["dwt_m"]

# add a multiplicative term incorporating the above pre
# - calculate the average values of predictor variables
avg_pet_p_ratio = dataset["pet_p_ratio"].mean()
avg_dwt_m       = dataset["dwt_m"].mean()
# - using the centered values
multiplicative_term = (dataset["pet_p_ratio"] - avg_pet_p_ratio) * (dataset["dwt_m"] - avg_dwt_m)
predictors["multiplicative_term"] = multiplicative_term
print(multiplicative_term)

# target variable
target = dataset["Applicability_tau_yr"].astype(float)
print(target)

# fit the model using all data
mlr_model = LinearRegression()
mlr_model.fit(predictors, target)

# intercept and regression coefficients
print(mlr_model.intercept_)
print(mlr_model.coef_)
# ~ -13.130654161539773
# ~ [ 2.66284398  0.41955129 -0.09452936]

# calculate performance values
# ~ predict
