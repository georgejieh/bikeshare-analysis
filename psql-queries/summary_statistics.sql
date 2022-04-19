-- ride_types table
SELECT * FROM ride_types;

-- ride_times table
SELECT * FROM ride_times;

-- joined table
SELECT t.ride_id, t.rideable_type, t.member_casual, ti.ride_length, ti.day_of_week, ti.season, ti.month_of_year
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id;

-- total amount of usable ride data record
SELECT COUNT(*) AS total_amount_of_rides FROM ride_types;

-- mode of day of the week
SELECT MODE() WITHIN GROUP (ORDER BY day_of_week) AS mode_of_day_of_week FROM ride_times;

-- median ride length in seconds
SELECT ride_length AS median_ride_length
FROM ride_times 
ORDER BY ride_length
OFFSET (
	SELECT COUNT(*) FROM ride_times)/2
LIMIT 1;

-- average ride length in seconds
SELECT AVG(ride_length) as avg_ride_length FROM ride_times;

-- max ride length in seconds
SELECT ride_length AS max_ride_length
FROM ride_times
ORDER BY ride_length DESC
LIMIT 1;

-- average ride length in seconds per day of week
SELECT day_of_week, AVG(ride_length) as avg_ride_length 
FROM ride_times
GROUP BY day_of_week;

-- number of rides per day of the week
SELECT day_of_week, COUNT(*) as number_of_rides 
FROM ride_times
GROUP BY day_of_week;

-- number of member/casual rides per day of the week
SELECT ti.day_of_week,
	SUM(CASE WHEN t.member_casual = 'member' then 1 ELSE 0 END) as number_of_member_rides,
	SUM(CASE WHEN t.member_casual = 'casual' then 1 ELSE 0 END) as number_of_casual_rides
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY ti.day_of_week;

-- average ride length in seconds per member/casual
SELECT t.member_casual, AVG(ti.ride_length) as avg_ride_length
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY t.member_casual;

-- average ride length in seconds per member/casual per day of the week
SELECT ti.day_of_week, t.member_casual, AVG(ti.ride_length) as avg_ride_length
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY ti.day_of_week, t.member_casual;

-- average ride length in seconds per rideable type
SELECT t.rideable_type, AVG(ti.ride_length) as avg_ride_length
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY t.rideable_type;

-- most common rideable type
SELECT MODE() WITHIN GROUP (ORDER BY rideable_type) AS mode_of_rideable_type FROM ride_types;

-- number of rides per rideable type
SELECT rideable_type, COUNT(*) as number_of_rides 
FROM ride_types
GROUP BY rideable_type;

-- number of rides from member/casual per rideable type
SELECT rideable_type, 
	SUM(CASE WHEN member_casual = 'member' then 1 ELSE 0 END) as number_of_member_rides,
	SUM(CASE WHEN member_casual = 'casual' then 1 ELSE 0 END) as number_of_casual_rides
FROM ride_types
GROUP BY rideable_type;

-- average ride length in seconds per rideable type per member/casual
SELECT t.rideable_type, t.member_casual, AVG(ti.ride_length) as avg_ride_length
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY t.rideable_type, t.member_casual;

-- number of member/casual rides per season
SELECT ti.season,
	SUM(CASE WHEN t.member_casual = 'member' then 1 ELSE 0 END) as number_of_member_rides,
	SUM(CASE WHEN t.member_casual = 'casual' then 1 ELSE 0 END) as number_of_casual_rides
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY ti.season;

-- number of member/casual rides per month
SELECT ti.month_of_year,
	SUM(CASE WHEN t.member_casual = 'member' then 1 ELSE 0 END) as number_of_member_rides,
	SUM(CASE WHEN t.member_casual = 'casual' then 1 ELSE 0 END) as number_of_casual_rides
FROM ride_types t
JOIN ride_times ti ON t.ride_id = ti.ride_id
GROUP BY ti.month_of_year;

-- median ride length per month
SELECT month_of_year, ROUND(median(ride_length), 2) AS median_ride_length
FROM ride_times 
GROUP BY month_of_year;

-- median ride length per season
SELECT season, ROUND(median(ride_length), 2) AS median_ride_length
FROM ride_times 
GROUP BY season;