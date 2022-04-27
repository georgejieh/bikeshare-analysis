# import data
setwd("/Users/nancy/Documents/Git Repo/Google Case Studies/bikeshare-analysis/processed-data/csv-files-for-import")
getwd()
data1 <- read.csv("ride_types.csv", stringsAsFactors = T)
data2 <- read.csv("ride_times.csv", stringsAsFactors = T)
data <- merge(data1, data2, by.x = "ride_id", by.y = "ride_id")
head(data)
str(data)
summary(data)

#delete useless data
data$ride_id <- NULL
rm(data1, data2)

# install and activate ggplot2
install.packages("ggplot2")
library(ggplot2)

