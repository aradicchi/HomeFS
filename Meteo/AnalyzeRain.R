library(ggplot2)
library(dplyr)

setwd("C:/Users/Rada/Codes/Net/HomeFS/Meteo/")

source("AnalyzeTemperatures.R")

rainuniv <- filter(readTemp("Data/dext3r/rain/rain_univ.csv","UNIV"),!is.na(Rain))
rainurb <-  filter(readTemp("Data/dext3r/rain/rain_urbana.csv","URB"),!is.na(Rain))
fullrain <- rbind(rainuniv,filter(rainurb,RefDate > max(rainuniv$RefDate)))
fullrain$Month <- as.integer(format(fullrain$RefDate,"%m"))
fullrain$MonthId <- as.factor(fullrain$Month)
fullrain$Year <- as.factor(format(fullrain$RefDate,"%Y"))

sumrain <- fullrain %>% group_by(Year,Month) %>% summarise(RainSum = sum(Rain))
sumrain$MonthId <- as.factor(sumrain$Month)

p <- ggplot(data=filter(sumrain,Year!='2017'),aes(reorder(MonthId,-Month),RainSum,col=Year)) + 
  geom_jitter(width=0.1,alpha=0.5,shape=0) +
  geom_jitter(width=0.1,shape=16,data=filter(sumrain,Year=='2017'),aes(MonthId,RainSum,col=Year),colour="orange") +
  coord_flip() +
  scale_y_continuous(name="Rain (kg/mq)") +
  scale_x_discrete(name="Month") +  
  #scale_colour_gradientn(colours=terrain.colors(3)) +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12))
p