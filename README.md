# Bike-Share Usage Analysis

![Bike-Share Image](https://i.imgur.com/trZS04H.png)

## Project Overview

This project analyzes bike-share usage data to understand differences between annual members and casual riders. The insights are aimed at developing strategies to convert casual riders into annual members and optimize marketing efforts.

## Business Objective

- Identify usage pattern differences between annual members and casual riders
- Analyze factors that might influence casual riders to purchase annual memberships
- Develop data-driven marketing recommendations

## Key Stakeholders

- Director of Marketing
- Marketing and Analytics Team
- Executive Team

## Data Source

This analysis uses public trip data provided by Motivate International Inc. under this [license](https://ride.divvybikes.com/data-license-agreement). The data covers bike rides for the year 2021 and is available from [this source](https://divvy-tripdata.s3.amazonaws.com/index.html).

## Methodology

### Data Preparation

The analysis workflow included:
1. Downloading monthly trip data for 2021
2. Standardizing file naming conventions
3. Converting files to appropriate formats for analysis
4. Initial data quality assessment

Limitations identified:
- Some rows missing station information
- Inconsistent station ID formats
- Geographic data reliability issues

### Data Processing

#### Tool Selection

To process and clean the data, Microsoft Excel was chosen as the primary tool. This tool was selected because the full dataset was divided into smaller chunks manageable via Excel, and Excel would be used for preliminary analysis later on.

#### Data Cleaning Process

The initial cleaning process involved:
1. Creating duplicates of each file in the project's /processed-data/xls-files directory
2. Removing problematic data points, including start/end station names and IDs due to inconsistencies
3. Standardizing data formats and syntax
4. Removing a small number of records with non-standard ride_id formats

#### Preliminary Calculations

Several calculated fields were created to facilitate analysis:

**Ride Length Calculation**
```Excel
= [ended_at] - [started_at]
```

This calculation yielded fractional time values that were formatted into HH:MM:SS syntax for better readability. Rows with negative ride length values (indicating data errors) were deleted.

**Day of the Week Extraction**
```Excel
= WEEKDAY([started_at],1) - 1
```

The WEEKDAY() function extracts day of the week information from timestamps. We adjusted the value by subtracting 1 to match SQL's day mapping scheme (0=Sunday through 6=Saturday).

**Distance Traveled Calculation**
For geographic distance calculations, the Haversine formula was implemented:

$$
Distance = R \times arccos[(sin\varphi_1 \times sin\varphi_2) + cos\varphi_1 \times cos\varphi_2\times cos\Delta\lambda]
$$

Where φ is latitude in radians, λ is longitude in radians, and R is Earth's radius (6377.83 miles). The radians conversion is calculated as:

$$
\phi = \frac{latitude}{(180/\pi)}
$$

$$
\lambda = \frac{longitude}{(180/\pi)}
$$

In Excel, this was implemented as:
```Excel
= 6377.83 * ACOS((SIN(RADIANS([start_lat]))*SIN(RADIANS([end_lat])))+COS(RADIANS([start_lat]))*COS(RADIANS([end_lat]))*COS(RADIANS([end_lng])-RADIANS([start_lng])))
```

However, this calculation was ultimately omitted from analysis after discovering that start and end locations don't accurately capture the actual distance traveled, as users simply return bikes to the nearest station.

### Analysis Methodology

#### Excel Analysis

Additional calculated fields were created for deeper analysis:

**Seasonal Classification**
```Excel
=LOOKUP(MONTH([started_at]),{1,2,5,8,11;"Winter","Spring","Summer","Autumn","Winter"})
```

This formula categorizes trips by season based on the month.

**Binary Indicators**
For pivot table analysis, binary fields were created:
```Excel
=IF([member_casual]="member",1,0)
```

These fields enabled count aggregations in pivot tables.

#### SQL Analysis

A PostgreSQL database was created with the following schema:

```sql
CREATE TABLE ride_types (
    ride_id VARCHAR(16) PRIMARY KEY,
    rideable_type VARCHAR(13) NOT NULL,
    member_casual VARCHAR(6) NOT NULL
);

CREATE TABLE ride_times (
    ride_id VARCHAR(16) NOT NULL,
    ride_length INTEGER NOT NULL,
    day_of_week SMALLINT NOT NULL,
    season VARCHAR(6) NOT NULL,
    month_of_year SMALLINT NOT NULL,
    FOREIGN KEY(ride_id) REFERENCES ride_types(ride_id)
);

CREATE TABLE ride_dates (
    ride_id VARCHAR(16) NOT NULL,
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP NOT NULL,
    FOREIGN KEY(ride_id) REFERENCES ride_types(ride_id)
);
```

A custom median function was implemented for statistical analysis:

```sql
CREATE OR REPLACE FUNCTION _final_median(numeric[])
   RETURNS numeric AS
$$
   SELECT AVG(val)
   FROM (
     SELECT val
     FROM unnest($1) val
     ORDER BY 1
     LIMIT  2 - MOD(array_upper($1, 1), 2)
     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
   ) sub;
$$
LANGUAGE 'sql' IMMUTABLE;

CREATE AGGREGATE median(numeric) (
  SFUNC=array_append,
  STYPE=numeric[],
  FINALFUNC=_final_median,
  INITCOND='{}'
);
```

#### R Analysis Methodology

The R analysis process included:

```R
# install and activate necessary packages
install.packages('tidyverse')
library(tidyverse)

# import data
setwd(".../bikeshare-analysis/processed-data/csv-files-for-import")
getwd()
data1 <- read.csv("ride_types.csv", stringsAsFactors = T)
data2 <- read.csv("ride_times.csv", stringsAsFactors = T)
data <- merge(data1, data2, by.x = "ride_id", by.y = "ride_id")
```

Data preparation:
```R
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
```

## Analysis Findings

### Key Statistics

| Description                                | Value                                     |
| ------------------------------------------ | ----------------------------------------- |
| Average Ride Length                        | 22 Minutes and 23 Seconds                 |
| Longest Ride Length                        | 33 Days 4 Hours 16 Minutes and 42 Seconds |
| Median Ride Length                         | 11 Minutes and 34 Seconds                 |
| Day with Most Rides                        | Saturday                                  |
| Annual Member Trip Percentage              | 52.51%                                    |
| Casual Rider Trip Percentage               | 47.49%                                    |
| Annual Member Preferred Bike Type          | Classic Bikes                             |
| Casual Rider Preferred Bike Type           | Electric Bikes                            |

### Usage Pattern Analysis

#### Membership Type Analysis by Day of Week

| Day of the Week | Avg Member Ride (sec) | Avg Casual Ride (sec) | Member Median (sec) | Casual Median (sec) | Max Member Ride (sec) | Max Casual Ride (sec) |
| --------------- | --------------------- | --------------------- | ------------------- | ------------------- | --------------------- | --------------------- |
| Sunday          | 948                   | 2374                  | 621                 | 1047                | 89995                 | 2137331               |
| Monday          | 865                   | 1717                  | 558                 | 893                 | 89995                 | 444809                |
| Tuesday         | 802                   | 1608                  | 546                 | 835                 | 89993                 | 372832                |
| Wednesday       | 800                   | 1585                  | 554                 | 794                 | 89990                 | 975130                |
| Thursday        | 785                   | 1720                  | 538                 | 782                 | 89996                 | 2498731               |
| Friday          | 817                   | 1977                  | 553                 | 824                 | 89996                 | 2866602               |
| Saturday        | 928                   | 1975                  | 651                 | 1015                | 89994                 | 412689                |

This analysis reveals:
- Annual members show consistent ride lengths during weekdays (approximately 800 seconds) with slight increases on weekends
- Casual riders' ride lengths fluctuate more, decreasing mid-week and increasing toward weekends
- Maximum ride durations for members never exceed 25 hours, while casual riders sometimes keep bikes for multiple days

#### Bike Type Usage Analysis

| Bike Type | Avg Member Ride (sec) | Avg Casual Ride (sec) |
| --------- | --------------------- | --------------------- |
| Classic   | 894                   | 2088                  |
| Docked    | 0                     | 6040                  |
| Electric  | 747                   | 1161                  |

Key findings:
- Annual members do not use docked bikes at all
- Electric bike trips are consistently shorter for both user types (likely due to faster speeds)
- Casual riders keep bikes significantly longer across all bike types

## Data Visualization Insights

### Ride Patterns by Bike Type and Season

![Bike Type Usage by Season](https://i.imgur.com/uk50Tpr.png)

This visualization shows:
- Classic bike usage dominates in summer and spring
- Electric bike usage increases in autumn
- Winter sees reduced usage across all bike types

### Weekly Riding Patterns

![Member vs Casual Weekly Trends](https://i.imgur.com/oQeA2u4.png)

![Member vs Casual Bike Type](https://i.imgur.com/mgRo4Mu.png)

These charts demonstrate:
- Annual members ride consistently throughout weekdays with slight weekend decreases
- Casual riders show dramatic increases in weekend usage
- Annual members strongly prefer classic bikes
- Casual riders show more balanced preference between electric and classic bikes

### Ride Length Statistical Analysis

![Ride Length by Season and Membership](https://i.imgur.com/L1xpxIq.png)

![Ride Length by Day and Membership](https://i.imgur.com/Y4U3jHY.png)

![Ride Length by Month and Membership](https://i.imgur.com/5XRviBa.png)

![Ride Length by Bike Type and Membership](https://i.imgur.com/xEkt6qL.png)

These boxplots reveal:
- Casual riders have greater variability in ride lengths
- Both user types ride longer during spring and summer months
- Annual members' ride durations remain remarkably consistent through weekdays
- Docked bikes create outliers that skew casual rider statistics

### Ride Length Distribution

The histograms show the distribution of ride lengths by different variables:

![Ride Length Histogram by Month](https://i.imgur.com/LG0U24z.png)

![Ride Length Histogram by Season](https://i.imgur.com/fZQz64J.png)

![Ride Length Histogram by Day](https://i.imgur.com/6az0410.png)

Key observations:
- Despite long statistical tails, the majority of rides for both user types are between 6-16 minutes
- October shows a significant increase in electric bike usage
- August shows unusually low annual member ridership
- Ride lengths increase during vacation/holiday periods, especially for casual riders

### Tableau Interactive Dashboard

A comprehensive Tableau dashboard was created to provide interactive visualization of the data:

![Tableau Dashboard](https://i.imgur.com/7TlIjsu.png)

The dashboard, available [here](https://public.tableau.com/app/profile/george.jieh/viz/GoogleDataAnalyticsCase1ConsolidatedVisuals/Dashboard1), includes additional insights:
- Holiday and weekend markers based on the Chicago School District academic calendar
- Ride frequency versus ride duration analysis
- Comparative metrics between membership types

A key finding from this visualization is that, excluding docked bikes, people tend to ride more frequently during weekdays but for longer durations on holidays and weekends. This time difference is negligible for members but significant for casual riders.

## Key Insights

### 1. Usage Pattern Differences

- **Annual Members**:
  - Show consistent, predictable usage patterns throughout weekdays
  - Take shorter rides (average 12-15 minutes)
  - Never keep bikes for more than 24 hours
  - Primarily use classic bikes
  - Consistent riding behavior suggests commuting purposes

- **Casual Riders**:
  - Show sporadic usage with significant weekend spikes
  - Take longer rides (average 20-35 minutes, excluding docked bikes)
  - Occasionally keep bikes for multiple days
  - Prefer electric bikes but use all bike types
  - Variable behavior suggests primarily leisure use

### 2. Seasonal and Weather Effects

- All rider types show increased usage during spring and summer
- Winter shows significant decrease in ridership (Chicago's winter temperatures can reach 27°F)
- Autumn sees a shift toward electric bikes across both user types
- Weather appears to be a significant factor in ride length and frequency

### 3. Bike Type Preferences

- Electric bikes consistently result in shorter trip durations, likely due to faster speeds
- The preference for classic bikes among annual members suggests prioritization of cost efficiency
- Docked bikes are used exclusively by casual riders and often for much longer durations

### 4. Temporal Patterns

- Weekday riding is remarkably consistent for annual members
- Friday through Sunday show significant increases in casual ridership
- Monday shows decreased ridership across both user types
- Casual riders during Monday-Thursday follow similar patterns to annual members, suggesting potential conversion targets

## Strategic Recommendations

### Target Demographics for Conversion

Based on the analysis, the primary target groups for conversion from casual to annual membership are:
1. **Weekday Classic Bike Riders**: Casual riders who use classic bikes during weekdays likely have similar usage patterns to existing members
2. **Winter/Spring Riders**: Those who ride during less favorable weather conditions demonstrate commitment similar to annual members

### Marketing Strategy Recommendations

1. **Seasonal Promotions**:
   - Offer annual membership discounts during winter and spring
   - Target the transition seasons with conversion incentives
   - Develop "fair weather" membership options for those who only ride in better weather

2. **Weekday Focus**:
   - Implement targeted advertising for individuals with weekday riding patterns
   - Create weekday-specific membership benefits
   - Highlight cost savings for regular commuters

3. **Usage Pattern Analysis**:
   - Develop an algorithm to identify casual riders with member-like usage patterns
   - Create personalized conversion offers based on individual riding history
   - Implement a "trial" membership period during peak conversion likelihood

## Limitations and Future Research

### Data Limitations

- The analysis would benefit from trip route data to better understand trip purposes
- Demographic information would allow for more targeted marketing strategies
- Absence of precise geographic usage patterns limits location-based insights

### Future Analysis Opportunities

Additional data that would enhance this analysis includes:
- Trip route data to confirm commuting versus leisure usage
- Demographic information on riders for better segmentation
- Weather data correlation with usage patterns
- Pricing sensitivity analysis
- Long-term conversion rate tracking

## Technical Implementation Notes

The complete technical implementation including SQL queries, R code, and Tableau workbooks is available in the repository. The methodology emphasizes reproducibility and statistical validity while acknowledging data limitations.
