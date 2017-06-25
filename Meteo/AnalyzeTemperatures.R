library(ggplot2)
library(dplyr)
library(gridExtra)

setwd("C:/Users/Rada/Codes/Net/HomeFS/Meteo/")

readTemp <- function(filename,name)
{
  dat <- read.csv(filename)
  dat$RefDate <- as.Date(dat$StartTime)
  dat$EndTime <- NULL
  dat$StartTime <- NULL
  dat$Name <- name
  return(dat)
}

#
# preparing data
#

maxuniv <- readTemp("Data/dext3r/temperatures/maxtemp_univ.csv",as.factor("UNIV"))
maxuniv <- filter(maxuniv,!is.na(MaxTempCelsius))
minuniv <- readTemp("Data/dext3r/temperatures/mintemp_univ.csv",as.factor("UNIV"))
minuniv <- filter(minuniv,!is.na(MinTempCelsius))
maxurb <- readTemp("Data/dext3r/temperatures/maxtemp_urbana.csv",as.factor("URB"))
maxurb <- filter(maxurb,!is.na(MaxTempCelsius))
minurb <- readTemp("Data/dext3r/temperatures/mintemp_urbana.csv",as.factor("URB"))
minurb <- filter(minurb,!is.na(MinTempCelsius))

fullmax <- rbind(maxuniv,filter(maxurb,RefDate > max(maxuniv$RefDate)))
fullmin <- rbind(minuniv,filter(minurb,RefDate > max(minuniv$RefDate)))
fulltemp <- merge(fullmax,fullmin,by="RefDate")
fulltemp$Name <- fulltemp$Name.x
fulltemp$Name.x <- NULL
fulltemp$Name.y <- NULL
fulltemp$Month <- as.integer(format(fulltemp$RefDate,"%m"))
fulltemp$MonthId <- as.factor(fulltemp$Month)
fulltemp$Year <- as.integer(format(fulltemp$RefDate,"%Y"))

#
# plotting daily temp
#

p <- ggplot(data=filter(fulltemp,Year!='2017'),aes(reorder(MonthId,-Month),MaxTempCelsius)) +
  geom_jitter(width=0.1,alpha=0.05) + coord_flip() + 
  geom_jitter(width=0.1,data=filter(fulltemp,Year=='2017'),aes(MonthId,MaxTempCelsius),colour="orange") +
  scale_y_continuous(name="Max(T°C)") +
  scale_x_discrete(name="Month") +
  theme(legend.position="none")
p

p3 <- ggplot(data=filter(fulltemp,Year!='2017'),aes(reorder(MonthId,-Month),MaxTempCelsius)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 1) + coord_flip() + 
  geom_jitter(width=0.1,data=filter(fulltemp,Year=='2017'),aes(MonthId,MaxTempCelsius),colour="orange") +
  scale_y_continuous(name="Max T (°C)") +
  scale_x_discrete(name="Month") +
  ggtitle("Max daily T (°C) by month in Parma:\n1961-2016 (box) vs 2017 (orange jitter)") +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12))
p3

p4 <- ggplot(data=filter(fulltemp,Year!='2017'),aes(reorder(MonthId,-Month),MinTempCelsius)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 1) + coord_flip() + 
  geom_jitter(width=0.1,data=filter(fulltemp,Year=='2017'),aes(MonthId,MinTempCelsius),colour="orange") +
  scale_y_continuous(name="Min T (°C)") +
  scale_x_discrete(name="Month") +
  ggtitle("Min daily T (°C) by month in Parma:\n1961-2016 (box) vs 2017 (orange jitter)") +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12))
p4

grid.arrange(p4,p3,ncol=2)

p7 <- ggplot(data=fulltemp,aes(Year,MaxTempCelsius)) +
  geom_point(alpha=0.3) + 
  geom_smooth(method='lm',colour='red') +
  scale_y_continuous(name="T (°C)") +
  #facet_grid(Month ~ ., ncol=3)
  facet_wrap( ~ Month, nrow=1) +
  ggtitle("Daily Max T (°C) in Parma: 1961-2017") +
  theme(axis.text.x = element_blank(),axis.title.x = element_blank(), axis.ticks.x = element_blank(),
        plot.title = element_text(face="bold",size=12))
p7

#
# plotting monthly temp
#

avgtemp <- fulltemp %>% group_by(Year,Month) %>% summarise(avg=mean(MaxTempCelsius))
avgtemp$MonthId <- as.factor(avgtemp$Month)

p1 <- ggplot(data=filter(avgtemp,Year!='2017'),aes(reorder(MonthId,-Month),avg,col=Year)) +
  geom_jitter(width=0.1,alpha=0.5) + coord_flip() + 
  geom_jitter(width=0.1,size=2,data=filter(avgtemp,Year=='2017'),aes(MonthId,avg),colour="red") +
  scale_y_continuous(name="Max(T°C)") +
  scale_x_discrete(name="Month") +
  scale_colour_gradientn(colours=terrain.colors(3)) +
  ggtitle("Avg of Max T°C by month in Parma:\n1961-2016 vs 2017 (red)") +
  theme(plot.title = element_text(face="bold",size=16)) #legend.position="none",
p1

p2 <- ggplot(data=filter(avgtemp,Year!='2017'),aes(reorder(MonthId,-Month),avg,col=Year)) +
  geom_boxplot() + coord_flip() + 
  geom_jitter(width=0.1,size=2,data=filter(avgtemp,Year=='2017'),aes(MonthId,avg),colour="red") +
  scale_y_continuous(name="Max(T°C)") +
  scale_x_discrete(name="Month") +
  scale_colour_gradientn(colours=terrain.colors(3)) +
  ggtitle("Avg of Max T°C by month in Parma:\n1961-2016 vs 2017 (red)") +
  theme(plot.title = element_text(face="bold",size=16)) #legend.position="none",
p2

#
# faceted by max/min
#

facdata <- data.frame(RefDate = fulltemp$RefDate,Temp=fulltemp$MaxTempCelsius,Label="MAX")
facdata <- rbind(facdata,data.frame(RefDate = fulltemp$RefDate,Temp=fulltemp$MinTempCelsius,Label="MIN"))
facdata$Label <- factor(facdata$Label,c("MIN","MAX"),ordered=TRUE)
facdata$Month <- as.integer(format(facdata$RefDate,"%m"))
facdata$MonthId <- as.factor(facdata$Month)
facdata$Year <- as.factor(format(facdata$RefDate,"%Y"))

p5 <- ggplot(data=filter(facdata,Year!='2017'),aes(reorder(MonthId,-Month),Temp)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 1) + coord_flip() + 
  geom_jitter(width=0.1,alpha=0.5,data=filter(facdata,Year=='2017'),aes(MonthId,Temp),colour="orange") +
  scale_y_continuous(name="T (°C)") +
  scale_x_discrete(name="Month") +
  ggtitle("Daily T (°C) in Parma: 1961-2016 (box) vs 2017 (orange jitter)") +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12)) +
  facet_wrap(~ Label)
p5

p6 <- ggplot(data=filter(facdata,Year!='2017'),aes(reorder(MonthId,-Month),Temp,col=Year)) +
  geom_jitter(width=0.1,alpha=0.5,shape=0) + coord_flip() + 
  geom_jitter(width=0.1,shape=16,data=filter(facdata,Year=='2017'),aes(MonthId,Temp,col=Year),colour="orange") +
  scale_y_continuous(name="T (°C)") +
  scale_x_discrete(name="Month") +
  ggtitle("Daily T (°C) in Parma: 1961-2016 vs 2017 (orange)") +
  theme(legend.position="none",plot.title = element_text(face="bold",size=12)) +
  facet_wrap(~ Label)
p6

