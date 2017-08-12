library(ggplot2)
library(dplyr)

setwd("C:/Users/Rada/Codes/Net/HomeFS/Meteo/House")

data <- read.csv("data.csv")
data$time <- strptime(data$time,"%Y%m%d %H:%M:%S")

p <- ggplot(data,aes(x=time,y=hum)) + geom_line()
p
