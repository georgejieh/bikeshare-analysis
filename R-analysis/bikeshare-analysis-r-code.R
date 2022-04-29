# install and activate necessary packages
install.packages(c("readr", "dplyr", "tidyr", "ggplot2", "stringr"))
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# import data
setwd("/Users/nancy/Documents/Git Repo/Google Case Studies/bikeshare-analysis/processed-data/csv-files-for-import")
getwd()
data1 <- read.csv("ride_types.csv", stringsAsFactors = T)
data2 <- read.csv("ride_times.csv", stringsAsFactors = T)
data <- merge(data1, data2, by.x = "ride_id", by.y = "ride_id")
head(data)
str(data)
summary(data)

# delete useless data
data$ride_id <- NULL
rm(data1, data2)

# set factors for some integer columns
data$day_of_week <- as.factor(data$day_of_week)
data$month_of_year <- as.factor(data$month_of_year)

# rename factor levels
levels(data$day_of_week) <- c("Sun", "Mon", "Tue", "Wed", 
                              "Thu", "Fri", "Sat")
levels(data$month_of_year) <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

# convert ride times to minutes
data$ride_length <- data$ride_length/60

# box plots
boxplot_base <- ggplot(data=data, aes(y=ride_length, 
                                      colour=member_casual))

boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=season)) + 
  coord_cartesian(ylim=c(0,85))

boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=day_of_week)) + 
  coord_cartesian(ylim=c(0,85))

boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=month_of_year)) + 
  coord_cartesian(ylim=c(0,100))

boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=rideable_type)) + 
  coord_cartesian(ylim=c(0,115))

# histograms
histogram_base <- ggplot(data=data, aes(x=ride_length, fill=member_casual))

histogram_base + geom_histogram(binwidth=2, colour="white", alpha=0.65) + 
  geom_freqpoly(binwidth=2, aes(colour=rideable_type)) +
  facet_grid(month_of_year~member_casual) +
  coord_cartesian(xlim=c(0,35))
 
histogram_base + geom_histogram(binwidth=2, colour="white", alpha=0.65) + 
  geom_freqpoly(binwidth=2, aes(colour=rideable_type)) +
  facet_grid(season~member_casual) +
  coord_cartesian(xlim=c(0,40))

histogram_base + geom_histogram(binwidth=2, colour="white", alpha=0.65) + 
  geom_freqpoly(binwidth=2, aes(colour=rideable_type)) +
  facet_grid(day_of_week~member_casual) +
  coord_cartesian(xlim=c(0,35))
