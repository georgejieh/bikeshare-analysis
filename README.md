# Google Data Analytics Case Study 1: How Does a Bike-Share Navigate Speedy Success?

![alt text](https://i.imgur.com/trZS04H.png)

[toc]

## Introduction

Cyclistic is a bike-share company that is based in the Chicago area. Their bike-share program geatures more than 5800 bikes and 600 docking stations. The company sets itself apart by offering bike styles that are more inlusive to people with disabilities such as reclining bikes, hand tricycles, and cargo bikes. The expectation is about 30% of the trips are used for commute to work each day while the rest is geared towards leisure. The director of marketing believes Cyclistic's future sucess will depend on maximizing the number of annual memberships. The team would like to understand how casual rides and annual members use bikes different to come up with a new marketing strategy to convert casual riders to annual members. 

## Ask Phase

#### Business Task

Identify how annual members and casual riders use Cyclisti differently. Analyze why would casual riders consider buying Cyclistic annual memberships. Come up with methods for the company to use digital media to influence casual rider to become members.

#### Key Stake Holders

- **Lily Moreno:** Director of Marketing
- **Cyclistic Marketing and Analytics Team**
- **Cyclistic Executive Team**

## Prepare Phase

Cyclistic is a fictional company made for the purpose of this case study. The data that will be used for the analysis is provided by Motivate International Inc for the real company Divy (which is also known as Lyft Bikes and Scooters, LLC) under this [license](https://ride.divvybikes.com/data-license-agreement).

2021 trip data were downloaded from [here](https://divvy-tripdata.s3.amazonaws.com/index.html). The zip files were placed in the project folder under /2021-raw-trip-data/zip-files. The files were then unzipped and the resulting CSV files were placed in the /2021-raw-trip-data/csv-files directory. To simplify the file names, divvy was removed so the naming scheme was simplied to YYYYMM-subjectmatter format.  After the file names were changed, each file were then duplicated and converted to XLS files and placeded in the /2021-raw-trip-data/xls-files directory. This conversion was necessary for us to easily manipulate the data later on in Excel.

The data presented gives us insight into the trip behaviors of casual riders and annual members. Each row is labeled member or casual and shows what bike they rode and when they rode it. By looking at these data points we can come up with ride length, bike type, and ride frequency trends between the two types of riders.

A preliminary look at the data shows some issues. The data provides geographic information regarding the trips. However, quite a few rows are missing station information and the station IDs are not normalized i.e. some station IDs are labeled as 3 digit numbers, some as 5, while others are a combination of characters and numbers. All of this resulting in the geographic data to be not useful. 