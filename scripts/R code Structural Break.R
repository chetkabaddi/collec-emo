# This code uses Argentina as an example, same analysis is carried out for all other countries. 

# Reference

# R Core Team (2020). R: A language and environment for statistical
  computing. R Foundation for Statistical Computing, Vienna, Austria. URL
  https://www.R-project.org/.
  
A BibTeX entry for LaTeX users is

  @Manual{,
    title = {R: A Language and Environment for Statistical Computing},
    author = {{R Core Team}},
    organization = {R Foundation for Statistical Computing},
    address = {Vienna, Austria},
    year = {2020},
    url = {https://www.R-project.org/},
  }

##########################
### System information ###
##########################
#platform       x86_64-apple-darwin17.0 (64-bit)
#arch           
#os                                  
#system                      
#status                                     
#major                                     
#minor                                   
#year                                   
#month                                    
#day                                      
#svn rev                               
#language       R                           
#version.string R version 4.0.2 (2020-06-22)
#nickname       Taking Off Again    

### PACKAGES REQUIRED ###

library(tseries)
library(forecast)
library(ggfortify)
library(strucchange)
library(urca)


##############################
# Read data
##############################

TSdata <- read.csv("/Users/vivek/Desktop/COVIDtw/Writing/Final Data Reanalysis_3Oct21.csv", header = T)


###########################
####### Argentina #########
###########################

ARGdata <- subset(TSdata, country == "ARG")
head(ARGdata)
ARGdate <- (ARGdata$date)

## Creating TS Object ##

startdate<- ARGdata$date[1]
startdate
startdate1 <- as.Date("2020-01-27")

enddate <- as.Date("2020-05-18")
inds <- seq(startdate1, enddate, by = "day")
inds
inds[1]


ARGts <- ts(ARGdata, start = c(2020, as.numeric(format(inds[1], "%j"))), frequency = 366)
ARGts

data.frame(ARGdate, inds)

Time <- data.frame(time(ARGts), ARGdata$date)
colnames(Time) <- c("Tmyst", "date1")
Time



################ Stationarity test ############ 
library(tseries)
library(forecast)
#########################

plot(ARGts[,5])
ARGPositiveEmotions<-ARGts[,5]
ARGPositiveEmotions
adf.test(ARGPositiveEmotions)
pp.test(ARGPositiveEmotions)
kpss.test(ARGPositiveEmotions, null = c("Level")) 
kpss.test(ARGPositiveEmotions, null = c("Trend")) 
adf.test(ARGPositiveEmotions, alternative = c("stationary"))
adf.test(ARGPositiveEmotions, alternative = c("explosive"), k = 4)
tseries::adf.test(ARGPositiveEmotions, k = 0) 

forecast::ndiffs(ARGts[,5], test = "adf")
forecast::ndiffs(ARGts[,5], test = "kpss")


############ 
plot(ARGts[,6])
ARGAnxiety<-ARGts[,6]
ARGAnxiety
adf.test(ARGAnxiety)
pp.test(ARGAnxiety)
kpss.test(ARGAnxiety, null = c("Level")) 
kpss.test(ARGAnxiety, null = c("Trend")) 
adf.test(ARGAnxiety, alternative = c("stationary"))
adf.test(ARGAnxiety, alternative = c("explosive"), k = 4)
tseries::adf.test(ARGAnxiety, k = 0) 

forecast::ndiffs(ARGts[,6], test = "adf")
forecast::ndiffs(ARGts[,6], test = "kpss")


################## End of Stationarity tests #################


##########################################
# Structural Change for Argentina
##########################################

library(ggfortify)
library(strucchange)
library(urca)

#########################################
# Positive Emotion: Structural Change
#########################################

# Zivot-Andrew test for structural break

#install.packages("urca")
ZA_ARG_PE<- ur.za(ARGPositiveEmotions, model="both")
ZA_ARG_PE
summary(ZA_ARG_PE)

ARGtest2_PE <- Fstats(ARGPositiveEmotions~1) #Gets a sequence of fstatistics for all possible 
# break points within the middle 70% of myts

plot(ARGtest2_PE, main = "F statistics for Structural Breaks in Positive Emotions: Argentina")
breakpoints(ARGtest2_PE)
lines(breakpoints(ARGtest2_PE))


ARGts.fs_PE <- ARGtest2_PE$Fstats #These are the fstats

bp.ARGts_PE <- breakpoints(ARGPositiveEmotions~1) #Gets the breakpoint based on the F-stats
summary(bp.ARGts_PE)

bd.ARGts_PE <- breakdates(bp.ARGts_PE) #Obtains the implied break data 

bd.ARGts_PE

sctest(ARGtest2_PE, type = c("expF")) #Obtains a p-value for the implied breakpoint

plot(bp.ARGts_PE, main = c("Breaks Points in Positive Emotion: Argentina"))



plot(ARGPositiveEmotions, xlab = c("Date"), ylab = c("Positive Emotion"), main = c("Structural Breaks in Positive Emotions: Argentina"))
## confidence intervals
ci.ARGts_PE <- confint(bp.ARGts_PE) #95% CI for the location break date
ci.ARGts_PE
lines(ci.ARGts_PE) #This shows the interval around the estimated break date

## fit null hypothesis model and model with 1 breakpoint
ARGfm0_PE <- lm(ARGPositiveEmotions ~ 1)
ARGfm1_PE <- lm(ARGPositiveEmotions ~ breakfactor(bp.ARGts_PE, breaks = 1))
coef(ARGfm1_PE)


plot(ARGPositiveEmotions, xlab = c("Date"), ylab = c("Positive Emotion"), main = c("Structural Breaks for Positive Emotion with Breakfactor: Argentina"))
lines(ts(fitted(ARGfm0_PE), start = c(2020.071)), col = "blue")
lines(ts(fitted(ARGfm1_PE), start = c(2020.071)), col = "dark Green")
lines(bp.ARGts_PE)
## confidence interval
ci.ARGts_PE <- confint(bp.ARGts_PE)
ci.ARGts_PE
lines(ci.ARGts_PE)

# PositiveEmotion Plot With Breaks: Argentina

ARG_PE_Fac <- breakfactor(bp.ARGts_PE)
ARGfm1_PE <- lm(ARGPositiveEmotions ~ ARG_PE_Fac - 1)
ARG_PE_fit0 <- ts(fitted(ARGfm0_PE))
ARG_PE_fit1 <- ts(fitted(ARGfm1_PE))
ARG_PE_org<- ts(ARGPositiveEmotions)


ts.plot(ARG_PE_org, ARG_PE_fit0, ARG_PE_fit1, gpars=list(xlab="Day", ylab="PositiveEmotion", lty=c(1,3,1)), lwd = c(1.5, 2.5, 1.5), col=c("blue", "dark gray", "dark green"), main = c("Structural Breaks for PositiveEmotion: Argentina"))
abline(v=c(bp.ARGts_PE$breakpoints +.5), lwd = 2, col = "red", lty = 2)



# Ploting retained breaks 
ARG_PE_fit0 <- ts(fitted(ARGfm0_PE))
ts.plot(ARG_PE_org, ARG_PE_fit0, ARG_PE_fit1, gpars=list(xlab="Day", ylab="PositiveEmotion", lty=c(1,3,1)), lwd = c(1.5, 2.5, 1.5), col=c("blue", "dark gray", "dark green"), main = c("Structural Breaks for PositiveEmotion: Argentina"))
abline(v=c(46), lwd = 2, col = "red", lty = 2)




