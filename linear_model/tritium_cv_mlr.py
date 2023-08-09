
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




