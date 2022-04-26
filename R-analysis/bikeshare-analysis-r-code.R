# import data
setwd("/Users/nancy/Documents/Git Repo/Google Case Studies/bikeshare-analysis/processed-data/csv-files-for-import")
getwd()
data1 <- read.csv("ride_types.csv", stringsAsFactors = T)
data2 <- read.csv("ride_times.csv", stringsAsFactors = T)
data3 <- merge(data1, data2, by.x = "ride_id", by.y = "ride_id")
head(data3)
str(data3)
summary(data3)

#delete useless data
data3$ride_id <- NULL

# install and activate ggplot2
install.packages("ggplot2")
library(ggplot2)


