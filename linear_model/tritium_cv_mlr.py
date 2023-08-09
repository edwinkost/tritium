
import pandas as pd
import numpy as np

# read dataset
dataset = pd.read_csv("../datasets/version_20230808/dataset_selected_20230808.csv", sep = ";")
# ~ print(dataset.to_string())

# calculate the average values of predictor variables
avg_pet_p_ratio = dataset["pet_p_ratio"].mean()
print(avg_pet_p_ratio)
avg_dwt_m       = dataset["dwt_m"].mean()
print(avg_dwt_m)

# centering predictor variables to their avearage values
ano_pet_p_ratio = pet_p_ratio - avg_pet_p_ratio
ano_dwt_m       = dwt_m       - avg_dwt_m
print(ano_pet_p_ratio, ano_dwt_m)

