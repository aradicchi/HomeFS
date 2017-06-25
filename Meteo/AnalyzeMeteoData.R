library(ggplot2)
library(zoo)
library(dplyr)

setwd("C:/Users/Rada/Codes/Net/HomeFS/Meteo")

# data_mix <- read.csv("Data/clean/parma_mix_1980_2017.csv")
# data_mix$StartDateTime <- as.Date(data_mix$StartDateTime)
# data_mix$EndDateTime  <- as.Date(data_mix$EndDateTime)
# 
# p <- ggplot(data=data_mix,aes(EndDateTime,Tot_KG_M2)) + geom_point()
# p <- p + stat_smooth(n=250)
# p

waitdays <- read.csv("Data/clean/waitdays.csv")
waitdays$dt <- as.Date(waitdays$dt)
waitdays$year <- as.numeric(format(waitdays$dt,"%Y"))
waitdays$month <- as.numeric(format(waitdays$dt,"%m"))

filtwdays <- subset(waitdays,waitdays$month <= 12)

#pwd <- ggplot(data=filtwdays,aes(month,wdays)) + geom_point()
#pwd <- pwd + geom_jitter()
#pwd <- pwd + facet_grid(month~year)
#pwd <- pwd + facet_wrap(~year,ncol=10)
#pwd

onlyrain <- subset(filtwdays,select=c(year,rainfall))
onlyrain$year <- as.factor(onlyrain$year)
p <- ggplot(data=onlyrain,aes(x=year,y=rainfall)) + geom_dotplot()
p
#agg <- summarize(onlyrain,by=list(filtwdays$year),FUN=sum)
grain <- summarize(group_by(onlyrain,year),totrain=sum(rainfall))
agrain <- arrange(grain,totrain)
p2 <- ggplot(data=agrain,aes(totrain)) + geom_point()
p2
#plot(agg$wdays,agg$rainfall)

wdaysseries <- zoo(waitdays$wdays,waitdays$dt)
wdaysmax <- rollmax(wdaysseries,100)
wdaysavg <- rollmean(wdaysseries,100)

windowed <- merge(fortify.zoo(wdaysseries),
                  fortify.zoo(wdaysmax))
windowed <- merge(windowed,
                  fortify.zoo(wdaysavg))

p1 <- ggplot(data=windowed,aes(x=index,y=wdaysmax)) + geom_line()
p1 <- p1 + geom_line(data=windowed,aes(x=index,y=wdaysavg))
p1
