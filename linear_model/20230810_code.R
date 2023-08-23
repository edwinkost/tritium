####You need to run this code in your default data directory 
##You can set the directory by the following code to load the data in 'GeospatialModel_20230509.csv'
##You need to intall package car for the vif function
##setwd('C:\\Users\\kp-chun\\OneDrive - UWE Bristol\\2022a\\Working2022 research\\B3 EJ\\05a GRL Revision\\20230509 Update Data\\20230510 Code save\\Code\\')
##setwd('C:\\Users\\kp-chun\\OneDrive - UWE Bristol\\2022a\\Working2022 research\\B3 EJ\\05a GRL Revision\\20230810 Update Data\\20230810 Code\\')
DataFrame<-read.csv('GeospatialModel_20230722.csv')


########################################
##Standard Least Squares

mean(DataFrame$pet_p)
mean(DataFrame$dwt)

SimpleModel<-lm(Applicability_tau~pet_p+dwt+I(pet_p-2.36136):I(dwt-116.15),DataFrame,weights=NULL)
summary(SimpleModel)

car::vif(SimpleModel)
confint(SimpleModel)


########################################
#plot(fitted(SimpleModel),DataFrame$Applicability_tau,ylab='Applicability_tau',xlab='Modelled value')
#abline(0,1)
