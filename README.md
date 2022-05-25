# Google Data Analytics Case Study 1: How Does a Bike-Share Navigate Speedy Success?

![alt text](https://i.imgur.com/trZS04H.png)



## Introduction

Cyclistic is a bike-share company that is based in the Chicago area. Their bike-share program features more than 5800 bikes and 600 docking stations. The company sets itself apart by offering bike styles that are more inclusive to people with disabilities such as reclining bikes, hand tricycles, and cargo bikes. The expectation is about 30% of the trips are used for commute to work each day while the rest is geared towards leisure. The director of marketing believes Cyclistic's future sucess will depend on maximizing the number of annual memberships. The team would like to understand how casual rides and annual members use bikes different to come up with a new marketing strategy to convert casual riders to annual members. 

## Ask Phase

#### Business Task

Identify how annual members and casual riders use Cyclistic differently. Analyze why would casual riders consider buying Cyclistic annual memberships. Come up with methods for the company to use digital media to influence casual rider to become members.

#### Key Stake Holders

- **Lily Moreno:** Director of Marketing
- **Cyclistic Marketing and Analytics Team**
- **Cyclistic Executive Team**

## Prepare Phase

Cyclistic is a fictional company made for the purpose of this case study. The data that will be used for the analysis is provided by Motivate International Inc for the real company Divy (which is also known as Lyft Bikes and Scooters, LLC) under this [license](https://ride.divvybikes.com/data-license-agreement).

2021 trip data were downloaded from [here](https://divvy-tripdata.s3.amazonaws.com/index.html). The zip files were placed in the project folder under /2021-raw-trip-data/zip-files. The files were then unzipped and the resulting CSV files were placed in the /2021-raw-trip-data/csv-files directory. To simplify the file names, divvy was removed so the naming scheme was simplified to YYYYMM-subjectmatter format.  After the file names were changed, each file were then duplicated and converted to XLS files and placeded in the /2021-raw-trip-data/xls-files directory. This conversion was necessary for us to easily manipulate the data later in Excel.

The data presented gives us insight into the trip behaviors of casual riders and annual members. Each row is labeled member or casual and shows what bike they rode and when they rode it. By looking at these data points we can come up with ride length, bike type, and ride frequency trends between the two types of riders.

A preliminary look at the data shows some issues. The data provides geographic information regarding the trips. However, quite a few rows are missing station information and the station IDs were not standardized i.e. some station IDs are labeled as 3 digit numbers, some as 5, while others are a combination of characters and numbers. All of this resulting in the geographic data to be not useful. 

## Process Phase

#### Tool Selection

To process and clean the data we choose to primarily use Microsoft Excel. This tool was chosen because the full dataset was divided into smaller bite size chunks that is still manageable via Excel. Also Excel would be used for preliminary analysis later on, so starting with Excel will make it more manageable. 

#### Initial Data Cleaning Process

To start the cleaning process we made duplicates of each XLS file and placed it in the project's /processed-data/xls-files directory. First we removeed the data points that were obviously problematic, which was the start station name and id, and end station name and id. Initially the goal was only to remove trips that had missing station names. While going through the process, we came to realize it would reduce sample size too much and impact data quality. As a result it is better to omit station names and not do analysis revolving around it then remove rows that will impact all types of analysis. Since station name related columns were removed, station id related columns are of no use by itself, so they were also removed.

The next step of the process was to make sure all data is standardized in format and/or syntax. By filtering ride_id column, it have came to our attention that a few handful of trip data have ride_ids that doesn't conform to 16 length alphanumeric format. With almost 200k rows of data, deleting a few handful of rows of trip data shouldn't impace data quality too much, so these trip data was removed to make importing to SQL database easier later on.   

#### Initial Preliminary Calculations

To make the data easier to work with, we've calculated each trip's ride length, distance traveled, and extracted day of the week information from the trip time stamps. 

###### Ride Length Calculation

To calculate ride length for each trip the following equation was used:

```Excel
= [ended_at] - [started_at]
```

More specifically ended_at is column D and started_at is column C. So for row 2, the equation will look as such:

```Excel
= D2 - C2
```

The result will show up as factional time. To make the result more understandable, the cells were then formated into HH:MM:SS syntax. For example the result for row 2 went from 0.007233796 to 00:10:25, which we can easily understand as 10 minutes and 25 seconds. 

After doing this calculation, we found a handfull of rows that would end up with negative ride length values. This is caused by the trip ending time being earlier than the trip starting time. This is clearly an error with the time tracking system, so these rows were deleted.

###### Day of the Week Extraction

To extract day of the week information from started_at time stamp, the following equation was used:

```Excel
= WEEKDAY([started_at],1) - 1
```

An example of this equation used for row 2, the equation would be written as:

```Excel
= WEEKDAY(C2,1) - 1
```

The WEEKDAY() function in excel extracts day of the week data from time stamps. The first variable designates the time stamp to be extracted and the second variable designates mapping scheme, also known as return type. There are 10 different return types and they display as follows:

| Return Type | Number Returned                           |
| ----------- | ----------------------------------------- |
| 1           | Numbers 1 (Sunday) through 7 (Saturday)   |
| 2           | Numbers 1 (Monday) through 7 (Sunday)     |
| 3           | Numbers 0 (Monday) through 6 (Sunday)     |
| 11          | Numbers 1 (Monday) through 7 (Sunday)     |
| 12          | Numbers 1 (Tuesday) through 7 (Monday)    |
| 13          | Numbers 1 (Wednesday) through 7 (Tuesday) |
| 14          | Numbers 1 (Tuesday) through 7 (Wednesday) |
| 15          | Numbers 1 (Friday) through 7 (Thursday)   |
| 16          | Numbers 1 (Saturday) through 7 (Friday)   |
| 17          | Numbers 1 (Sunday) through 7 (Saturday)   |

The return type that makes the most sense for our puposes is type 1, which is also the default return type used for this function. However SQL, which we will use later on, utilizes numbers 0 (Sunday) through 6 (Saturday) as it's day of the week mapping scheme, which is why the function result is minused by 1. 

###### Distance Traveled Calculation

To calculate distance travled, we will need to calculate the distanace between two longitude and latitude coordinates. For us to do so the Haversine formula would be needed. The Haversine formula is as follows:


$$
Distance = R \times arccos[(sin\varphi_1 \times sin\varphi_2) + cos\varphi_1 \times cos\varphi_2\times cos\Delta\lambda]
$$


φ is value of latitude in radians, λ is value of longtitude in radians, and R is earth's radius, which is approximately 3963 kilometers or 6377.83 miles. To calculate radians, the equation for latitude would be:


$$
\phi = \frac{latitude}{(180/\pi)}
$$


While the equation for longitude would be:


$$
\lambda = \frac{longitude}{(180/\pi)}
$$


Since we are using Excel, we can easily calculate radians with the function RADIANS(). So the full Haversine formula in Excel format with the result in miles will be the following:

```Excel
= 6377.83 * ACOS((SIN(RADIANS([start_lat]))*SIN(RADIANS([end_lat])))+COS(RADIANS([start_lat]))*COS(RADIANS([end_lat]))*COS(RADIANS([end_lng])-RADIANS([start_lng])))
```

An example of this equation used for row 2, the equation would be written as:

```Excel
= 6377.83 * ACOS((SIN(RADIANS(E2))*SIN(RADIANS(G2)))+COS(RADIANS(E2))*COS(RADIANS(G2))*COS(RADIANS(H2)-RADIANS(F2)))
```

After using this calculation we've realized it creates a few #NUM! errors. These errors are created when the bike was borrowed at and returned to the same exact location. This cause us to realize calculating distance won't be much of an insight because borrow and return locations have no direct correlation with how far the user actually rode. Since users will return the bike to the nearest station to where they end their trip. If the trip was a round trip, it would be parked close to the borrowed location. Ultimately this resulted in these calculations to be omitted and longitude and latitude data deleted during the cleaning process. 

## Analyze Phase

For the analyze step we decided to use Excel, SQL, and R. Each tool have it's strength and weaknesses, so we believed all three together will provide more insights into the data than just using any one of them.

#### Excel Analysis

To begin the process for Excel analysis we first need to combine all 12 XLS files into 1 XLSX file. We've created the XLSX file in the directory /processed-data/ and named it consolidated-processed-data. With the data merged, we prepared more calculations in preperation for pivot tables. 

###### Additional Calculations

One of the first calculation we did was to extract seasons from time stamp. By being able to group the data as season we can see trip trends across each season and determine if change in weather changes anything about user habits. To extract season information the following equation was used:

```Excel
=LOOKUP(MONTH([started_at]),{1,2,5,8,11;"Winter","Spring","Summer","Autumn","Winter"})
```

The equation extracts the month from started_at time stamp, and if the value is 11, 12, or 1 then it return the result Winter. If its between 2 to 5, then its Spring and so on. 

The next calculation was to extracting month from time stamp. All we need to do for this was to use the MONTH() function. 

The last set of calculation was all logical formulas. We want each trip to return a certain binary result based on a certain criteria. For example, if we want the data to return 1 if the bike trip was taken by an annual member and 0 if it wasn't, then we may use this equation:

```Excel
=IF([member_casual]="member",1,0)
```

The reason why we need the binary results is due to pivot tables later on. In pivot tables there isn't an option for you to count the number of a certain value out of a column that have multiple different values. For example, you cannot tell a pivot table to count the number of members in a column that have both members and casuals. However if you have a separate columns that returns 1 as a result for the trip being an annual membership trip, you can use sum to add up all the member trips.

###### Descriptive Analysis

For better organization, a new sheet named descriptive_analysis was created. In here we found out the following:

| Description                                | Value                                     |
| ------------------------------------------ | ----------------------------------------- |
| Average Ride Length                        | 22 Minutes and 23 Seconds                 |
| Longest Ride Length                        | 33 Days 4 Hours 16 Minutes and 42 Seconds |
| Median Ride Length                         | 11 Minutes and 34 Seconds                 |
| Day of the Week With Most Rides            | Saturday                                  |
| Percentage of Trips Made By Annual Members | 52.51%                                    |
| Percentage of Trips Made By Casual Riders  | 47.49%                                    |
| Preferred Bike Type by Annual Members      | Classic Bikes                             |
| Preferred Bike Type of Casual Riders       | Electric Bikes                            |

From the descriptive analysis we learned the following:

- Casual Riders and Annual Members rides very differently, with each have preferences over different bike types due to differences in usage purposes.
- Distribution of bike trips sways towards the weekends, which is in line with the expectation that the company have regarding 30% of trips being commutes while the rest being used for casual rides.
- The preference of Classic Bikes for Annual Members seems to indicate Annual Members uses the bikes for commute more often since Classic Bikes are lighter than Electric bikes, but the Annual Member versus Casual Member percentage trip distribution seems to go against the 30% : 70% ratio presented by the company.
- Majority of rides seems to be on the shorter end between 11 to 22 minutes.
- There are a few outliers where the ride length spans multiple days.

###### Pivot Tables

The next step of the analysis is to use pivot tables. In pivot tables we experimented with the data is various areas to look for patterns. 

Below are a few pivot tables that were generated:

![img](https://i.imgur.com/fDm7D4Y.png)

![img](https://i.imgur.com/KbNM9m7.png)

![img](https://i.imgur.com/11EtHJR.png)

![img](https://i.imgur.com/QloHCCb.png)

![img](https://i.imgur.com/A483Am0.png)

From the pivogt table we learn the following:

- The 33 Days + trip was taken by a casual rider during Spring of April on a docked bike. 
- Annual members on average takes shorter rides than casual riders, but at a slightly higher frequency.
- Annual members do not use docked bikes at all and most really long trips are docked bikes.
- If rows with problematic data were not deleted, the number of rides each month would be exactly the same, so we cannot determine which months or seasons people ride more often.
- We see a spike in trips on Fridays through Sundays. There is a dip in trip on Monday. While the number of trips between Tuesday through Thursday are fairly constant.
- With annual members, trip frequency from Tuesday through Saturday is fairly constant, while there is a dip on Sunday and Monday. 
- With casual riders the trip frequency between Monday to Thursday is fairly constant with a spike starting on Friday till Sunday.
- With the aforementioned patterns, most casual riders riding between Monday through Thursday could be riding for the same reasons as annual members between Tuesday through Thursday. They are possible targets for marketing.
- People tend to ride longer during spring and summer. Possibly due to nicer weather. While much shorter during winter. Keep in mind these trips takes place around Chicago area where winter can get as cold as 27 degrees Fahrenheit, while summers rarely get hotter than 82 degrees Fahrenheit.

### pSQL Analysis

To be able to drill into more details into the data that pivot tables can't accomplish, such as finding average annual member ride length per season, we've decided to use SQL for analysis as well. Out of all the SQL option, pSQL was chosen due to accessibility. 

###### pSQL Database Schema and Data Import

To keep each table from being too wide, the combined data was divided into three tables. One specifically for ride 
