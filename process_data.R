
## https://www.kaggle.com/c/sf-crime/data?train.csv.zip

setwd("~/mooc/devdataprod/sf-crime")

library(lubridate)

## load data
data <- read.csv('train.csv')

data$Week <- as.Date(data$Dates)-(wday(data$Dates)+5)%%7
data$PartOfDay <- hour(data$Dates) %/% 3
data$PartOfDay <- factor(data$PartOfDay, levels = 0:7,
                         labels = c("00:00-03:00", "03:00-06:00", "06:00-09:00", "09:00-12:00",
                                   "12:00-15:00", "15:00-18:00", "18:00-21:00", "21:00-00:00"))
data$Address <- NULL
data$Dates <- NULL


## load map
library(ggmap)
map <- get_map(location = c(-122.444172, 37.756432), zoom=12, 
               source = "stamen", maptype = "watercolor")

## save the result
save(data, map, file = "data.RData")

