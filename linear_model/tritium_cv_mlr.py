
import pandas as pd

# read dataset
dataset = pd.readcsv("..\datasets\version_20230808\dataset_selected_20230808.csv", sep = ";")

print(dataset.tostring())

