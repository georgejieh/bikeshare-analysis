# install and activate necessary packages
install.packages("ggplot2")
library(ggplot2)

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
levels(data$rideable_type) <- c("Classic", "Docked", "Electric")

# convert ride times to minutes
data$ride_length <- data$ride_length/60

# box plots
boxplot_base <- ggplot(data=data, aes(y=ride_length, 
                                      colour=member_casual))

boxplot1 <- boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=season)) + 
  coord_cartesian(ylim=c(0,85))

boxplot2 <- boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=day_of_week)) + 
  coord_cartesian(ylim=c(0,85))

boxplot3 <- boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=month_of_year)) + 
  coord_cartesian(ylim=c(0,100))

boxplot4 <- boxplot_base + geom_boxplot(size=1.10, outlier.shape = NA, aes(x=rideable_type)) + 
  coord_cartesian(ylim=c(0,115))

# histograms
histogram_base <- ggplot(data=data, aes(x=ride_length, fill=member_casual))

histogram1 <- histogram_base + geom_histogram(binwidth=2, colour="white", alpha=0.65) + 
  geom_freqpoly(binwidth=2, aes(colour=rideable_type)) +
  facet_grid(month_of_year~member_casual, scales="free") +
  coord_cartesian(xlim=c(0,35))
 
histogram2 <- histogram_base + geom_histogram(binwidth=2, colour="white", alpha=0.65) + 
  geom_freqpoly(binwidth=2, aes(colour=rideable_type)) +
  facet_grid(season~member_casual, scales="free") +
  coord_cartesian(xlim=c(0,40))

histogram3 <- histogram_base + geom_histogram(binwidth=2, colour="white", alpha=0.65) + 
  geom_freqpoly(binwidth=2, aes(colour=rideable_type)) +
  facet_grid(day_of_week~member_casual, scales="free") +
  coord_cartesian(xlim=c(0,35))

# themes and formatting

boxplot1
boxplot1 + xlab("Seasons") + ylab("Ride Length (minutes)") +
  ggtitle("Ride Length Distribution Over Seasons Between Members And Casuals") +
  theme(axis.title.x = element_text(size=12),
        axis.title.y = element_text(size=12),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10),
        legend.position = c(1,1),
        legend.justification = c(1,1),
        plot.title = element_text(size=18, hjust = 0.5))
boxplot2
boxplot2 + xlab("Day of the Week") + ylab("Ride Length (minutes)") +
  ggtitle("Ride Length Distribution Over Week Between Members And Casuals") +
  theme(axis.title.x = element_text(size=12),
        axis.title.y = element_text(size=12),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10),
        legend.position = c(1,1),
        legend.justification = c(1,1),
        plot.title = element_text(size=18, hjust = 0.5))
boxplot3
boxplot3 + xlab("Months") + ylab("Ride Length (minutes)") +
  ggtitle("Ride Length Distribution Over Months Between Members And Casuals") +
  theme(axis.title.x = element_text(size=12),
        axis.title.y = element_text(size=12),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10),
        legend.position = c(1,1),
        legend.justification = c(1,1),
        plot.title = element_text(size=18, hjust = 0.5))
boxplot4
boxplot4 + xlab("Bike Types") + ylab("Ride Length (minutes)") +
  ggtitle("Ride Length Distribution Over Bike Types Between Members And Casuals") +
  theme(axis.title.x = element_text(size=12),
        axis.title.y = element_text(size=12),
        axis.text.x = element_text(size=10),
        axis.text.y = element_text(size=10),
        legend.title = element_text(size=12),
        legend.text = element_text(size=10),
        legend.position = c(1,1),
        legend.justification = c(1,1),
        plot.title = element_text(size=18, hjust = 0.5))
