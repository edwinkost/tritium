
library("Metrics")

dataset = read.csv("../datasets/version_2022026/dataset_20220226.csv", header = TRUE, sep = ";", quote = "")

performance <- data.frame(matrix(ncol = 2, nrow = 0))

colnames(performance) <- c('rmse', 'rsquared')

for (val in seq(1,1000))
{

sample = dataset[sample(nrow(dataset),22),]; rmse = rmse(sample$Validity, sample$SimpleModel); lm_model = lm(sample$Validity ~ sample$SimpleModel); rsquared = summary(lm_model)$r.squared; print(c(rmse, rsquared))

performance[nrow(performance) + 1,] = c(rmse, rsquared)

}
