######################################################
###############COVID-19 Twitter#######################
######################################################

##########################
### System information ###
##########################
#platform       x86_64-w64-mingw32          
#arch           x86_64                      
#os             mingw32                     
#system         x86_64, mingw32             
#status                                     
#major          4                           
#minor          0.4                         
#year           2021                        
#month          02                          
#day            15                          
#svn rev        80002                       
#language       R                           
#version.string R version 4.0.4 (2021-02-15)
#nickname       Lost Library Book     

setwd("~/COVID Project/Final Material/graph codes")

### PACKAGES REQUIRED
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(readr)


variablelist = c("posemo", "anx")

temp_data <- read_csv("Final Data Reanalysis_3Oct21.csv", 
                      col_types = cols(date = col_date(format = "%d/%m/%y"), 
                                       anger = col_skip(), sad = col_skip()))



##### CREATE NORMALISED VALUES FOR POSEMO AND ANX
temp_data <- temp_data %>% 
  group_by(country) %>% 
  mutate(mean_anx = mean(anx)) %>% 
  mutate(mean_posemo = mean(posemo)) %>% 
  mutate(normalised_anx = anx/mean_anx) %>% 
  mutate(normalised_posemo = posemo/mean_posemo)

##### PIVOT LONGER
temp_data %>% 
  select(c("date", "country_name", "country", "WC", "posemo", "anx", "normalised_posemo", "normalised_anx")) %>% 
  pivot_longer(cols = c(posemo, anx, normalised_anx, normalised_posemo),
               names_to = "variable",
               values_to = "value") %>% 
  write.csv(file = "longdata_for_graphs.csv")
                                              # The new CSV file is used for plotting all the graphs.

##### READ DATA FILE
data <- read_csv("longdata_for_graphs.csv")

##### REMOVE COUNTRIES THAT DON'T MEET THE SECOND CRITERION FOR INCLUSION
droplist <- c("BRA", "CHL", "PER")
data <- data %>% 
  filter(!country %in% droplist)

View(data)

##### SPECIFYING PARAMETERS FOR GRAPHS ###############

## The following creates colour palette for graphs
colours1 <- c("#ef72f7","#58b622","#4f4cd1","#2ce18b","#f948bd",
              "#bdd055","#53006c","#ffa13d","#003993","#965400",
              "#02d9eb","#ff6b72","#003864","#ffb488","#2a002a",
              "#efb0f6","#705200","#ff7caa","#7b004f")
colours2 <- c('#9A6324', '#800000', '#e6194B', '#3cb44b', '#ffe119', 
              '#4363d8', '#aaffc3', '#808000', '#000075', '#f58231', 
              '#911eb4', '#42d4f4', "#9e1309", '#a9a9a9', '#fabed4', 
              '#469990', '#dcbeff', '#bfef45','#f032e6' )
colours3 <- c('#ff0000', '#f77c7c', '#a82020', '#d400ff', '#ffc800',
              '#ffff00', '#b6b848', '#595858', '#55ff00', '#8ce690', 
              '#f3b5ff', '#0f0f0f', '#00fffb', '#0ca4eb', '#0004ff')

## Following is required for smoothing. LOESS smoothing is used and the span is -
  # - set for 28 days
total_days <- diff(range(data$date))
span <- 28/as.double(total_days, units = 'days')

##### WC for all countries ############
temp_data %>% 
  group_by(country_name) %>% 
  filter(!country %in% droplist) %>% 
  tally(WC) %>% 
  write.csv(file = "total word count from R.csv")

##### Series Mean and SD for each country ############
data %>% 
  filter(variable %in% variablelist) %>% 
  group_by(country_name, variable) %>% 
  summarise(mean(value), sd(value)) %>% 
  write.csv(file = "mean&sd for 16 countries.csv")

###### Segment Mean and SD for each country ##########
data %>% 
  filter(country_name == "Germany") %>% 
  filter(between(date, as.Date("2020-03-11"),as.Date("2020-05-18"))) %>% 
  filter(variable == "posemo") %>% 
  summarise(mean(value), sd(value)) 

######ggplot for nornalised scores on anxiety and posemo showing the system turn#############

normalised_plot <- data %>% 
  filter(!variable %in%variablelist) %>% 
  ggplot(aes(x = date, y = value, color = variable)) +
  geom_smooth(method = "loess", span = span, alpha = 0.1)+
  facet_wrap("country_name", nrow = 5, scales = "free_y")+
  xlab("First 120 days of the pandemic")+
  ylab("Normalised anxiety and posemo")+
  theme_minimal()
normalised_plot

##########Time series plots that go in the paper #####################

## Plot for anxiety
smooth_anx <- data %>% 
  filter(variable == "anx") %>% 
  ggplot(aes(x = date, y = value, color = country_name)) +
  geom_smooth(method = "loess", span = span, alpha = 0.05)+
  #geom_vline(aes(xintercept = as.Date("2020-03-11")), linetype = 5)+
  scale_color_manual(values = colours1)+
  #xlab("First 120 days of the pandemic")+
  ylab("Anxiety levels in daily meta-text")+
  theme_minimal()
smooth_anx

## Plot for posemo
smooth_posemo <- data %>% 
  filter(variable == "posemo") %>% 
  ggplot(aes(x = date, y = value, color = country_name)) +
  geom_smooth(method = "loess", span = span, alpha = 0.05)+
  #geom_vline(aes(xintercept = as.Date("2020-03-11")), linetype = 5)+
  scale_color_manual(values = colours1)+
  xlab("First 120 days of the pandemic")+
  ylab("Posemo levels in daily meta-text")+
  theme_minimal()
smooth_posemo

## Combine plots
smooth_final_plot <- ggarrange(
  smooth_anx,smooth_posemo,
  ncol = 1,
  nrow = 2,
  labels = "",
  label.x = c(0),
  label.y = c(0.5),
  hjust = -0.5,
  vjust = 1.5,
  font.label = list(size = 14, color = "black", face = "bold", family = NULL),
  align = c("none", "h", "v", "hv"),
  widths = 1,
  heights = 1,
  legend = "right",
  common.legend = TRUE,
  legend.grob = NULL
)
smooth_final_plot

################ calculations scratchpad
temp_data %>% 
  filter(!country %in% droplist) %>% 
  group_by(country) %>% 
  summarise(mean = mean(WC), StdDev = sd(WC)) %>% 
  arrange(mean)
