library(ggplot2)
library(dplyr)
library(zoo)

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

series <- zoo(fullrain$Rain,fullrain$RefDate)
sumseries <- rollsum(series,12*30,align='right')
dfsum <- fortify(sumseries)
dfsum$Month <- as.integer(format(dfsum$Index,"%m"))
dfsum$MonthId <- as.factor(dfsum$Month)
dfsum$Year <- as.factor(format(dfsum$Index,"%Y"))

p1 <- ggplot(data=filter(dfsum,Year!='2017'),aes(reorder(MonthId,-Month),sumseries,col=Year)) + 
  geom_jitter(width=0.1,alpha=0.5,shape=0) +
  geom_jitter(width=0.1,shape=16,data=filter(dfsum,Year=='2017'),aes(MonthId,sumseries,col=Year),colour="orange") +
  coord_flip() +
  scale_y_continuous(name="Rain (kg/mq)") +
  scale_x_discrete(name="Month") +  
  #scale_colour_gradientn(colours=terrain.colors(3)) +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12))
p1

p1_2 <- ggplot(data=filter(dfsum,Year!='2017'),aes(reorder(MonthId,-Month),sumseries)) + 
  geom_boxplot(outlier.color = "red") +
  geom_jitter(width=0.1,shape=16,data=filter(dfsum,Year=='2017'),aes(MonthId,sumseries,col=Year),colour="orange") +
  coord_flip() +
  scale_y_continuous(name="Rain (kg/mq)") +
  scale_x_discrete(name="Month") +  
  #scale_colour_gradientn(colours=terrain.colors(3)) +
  ggtitle("Rolling 6M cumulated rain in Parma:\n1961-2016 (box) vs 2017 (orange jitter)") +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12))
p1_2

p2 <- ggplot(data=dfsum,aes(Index,sumseries)) + 
  geom_point() +
  geom_smooth()
p2

avgseries <- rollmean(series,6*30,align="right")
dfavg <- fortify(avgseries)
dfavg$Month <- as.integer(format(dfavg$Index,"%m"))
dfavg$MonthId <- as.factor(dfavg$Month)
dfavg$Year <- as.factor(format(dfavg$Index,"%Y"))

p3 <- ggplot(data=dfavg,aes(Index,avgseries)) + 
  geom_point() +
  geom_smooth()
p3

means <- rollmean(series,365*5,align="right")
longavgrain <- fortify(means)
p4 <- ggplot(data=longavgrain,aes(Index,means)) + geom_line()
p4
