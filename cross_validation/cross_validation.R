
library("Metrics")

#~ dataset = read.csv("../datasets/version_20220226/dataset_20220226.csv", header = TRUE, sep = ";", quote = "")
dataset    = read.csv("../datasets/version_20230509/dataset_20230509.csv", header = TRUE, sep = ";", quote = "")

performance <- data.frame(matrix(ncol = 3, nrow = 0))

colnames(performance) <- c('rmse', 'r_squared', 'adj_r_squared')

for (val in seq(1,1000))
{

sample = dataset[sample(nrow(dataset),22),]; 
rmse = rmse(sample$Validity, sample$SimpleModel); 

lm_model      = lm(sample$Validity ~ sample$SimpleModel); 
r_squared     = summary(lm_model)$r.squared
adj_r_squared = summary(lm_model)$adj.r.squared

print(c(rmse, r_squared, adj_r_squared))

performance[nrow(performance) + 1,] = c(rmse, r_squared, adj_r_squared)

}

mean(performance$rmse)
mean(performance$adj_r_squared)

median(performance$rmse)
median(performance$adj_r_squared)

sd(performance$rmse)
sd(performance$adj_r_squared)

#~ hist(performance$rmse)
#~ hist(performance$adj_r_squared)

