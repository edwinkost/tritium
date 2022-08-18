####You need to run this code in your default data directory 
##You can set the directory by the following code to load the data in 'GeospatialModel_20220226.csv'
##setwd('C:\\Users\\Folders\\')
DataFrame<-read.csv('GeospatialModel_20220226.csv')


########################################
##Standard Least Squares
names(DataFrame)
lm(Applicability.tau~pet_p+dwt+I(pet_p-2.31136):I(dwt-110.477),DataFrame,weights=NULL)
lm(Applicability.tau~I(pet_p-2.31136)*I(dwt-110.477),DataFrame,weights=NULL)

SimpleModel<-lm(Applicability.tau~I(pet_p-2.31136)*I(dwt-110.477),DataFrame,weights=NULL)
summary(SimpleModel)

SimpleModel<-lm(Applicability.tau~pet_p+dwt+I(pet_p-2.31136):I(dwt-110.477),DataFrame,weights=NULL)
summary(SimpleModel)


########################################
##Standard Least Squares
names(DataFrame)

lm(Applicability.tau~I(aet_p-0.82955)*I(pet_p-2.31136)+I(aet_p-0.82955)*I(dwt-110.477)+I(pet_p-2.31136)*I(dwt-110.477),DataFrame,weights=NULL)
lm(Applicability.tau~pet_p+aet_p+dwt+I(aet_p-0.82955):I(pet_p-2.31136)+I(aet_p-0.82955):I(dwt-110.477)+I(pet_p-2.31136):I(dwt-110.477),DataFrame,weights=NULL)

ComplexModel<-lm(Applicability.tau~I(aet_p-0.82955)*I(pet_p-2.31136)+I(aet_p-0.82955)*I(dwt-110.477)+I(pet_p-2.31136)*I(dwt-110.477),DataFrame,weights=NULL)
summary(ComplexModel)

ComplexModel<-lm(Applicability.tau~pet_p+aet_p+dwt+I(aet_p-0.82955):I(pet_p-2.31136)+I(aet_p-0.82955):I(dwt-110.477)+I(pet_p-2.31136):I(dwt-110.477),DataFrame,weights=NULL)
summary(ComplexModel)

