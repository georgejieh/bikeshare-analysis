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

# install and activate ggplot2
install.packages("ggplot2")
library(ggplot2)

# bar charts
bar_base <- ggplot(data=data, aes(x=member_casual))
geom_bar_base <- geom_bar(stat="count", colour="black", aes(fill=category))

category <- data$season
bar_base + geom_bar_base

category <- data$day_of_week
bar_base + geom_bar_base

category <- data$rideable_type
bar_base + geom_bar_base

category <- data$month_of_year
bar_base + geom_bar_base
