## Imputing data for missing values with an example of Argentina 


##################################
# Import data

# Argentina_LIWC is a data with missing values
##################################


##################################
# Imputing values 
##################################
#install.packages("Amelia")
# install.packages("Amelia", repos = "http://gking.harvard.edu")

library(Amelia)
# update.packages("Amelia")
# AmeliaView()
# install.packages("mtsdi")
names(Argentina_LIWC)

aout1 <- amelia(Argentina_LIWC, m = 20, p2s = 1,frontend = FALSE, idvars = "Sr", ts = "date1", cs = NULL, polytime = NULL, splinetime = NULL, intercs = FALSE, lags = NULL, leads = NULL, startvals = 0, tolerance = 0.0001, logs = NULL, sqrts = NULL, lgstc = NULL, noms = NULL, ords = NULL, incheck = TRUE, collect = FALSE, arglist = NULL, empri = NULL, priors = NULL, autopri = 0.05, emburn = c(50,100), bounds = NULL, max.resample = 100, overimp = NULL, boot.type = "ordinary", parallel = c("no"))

par(mfrow = c(4,2))
overimpute(aout1, var = ("EmoPos"))
overimpute(aout1, var = ("EmoNeg"))
overimpute(aout1, var = ("Ansiedad"))
overimpute(aout1, var = ("Enfado"))
overimpute(aout1, var = ("Triste"))


write.amelia(obj=aout1, separate = TRUE, file.stem= "Argentina_LIWC_amelimpute1WC", format="csv")


