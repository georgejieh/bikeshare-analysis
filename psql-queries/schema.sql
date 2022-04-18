CREATE TABLE ride_types
	(
		ride_id VARCHAR(16) PRIMARY KEY,
		rideable_type VARCHAR(13) NOT NULL,
		member_casual VARCHAR(6) NOT NULL
	);

CREATE TABLE ride_times
	(
		ride_id VARCHAR(16) NOT NULL,
		started_at TIMESTAMP NOT NULL,
		ended_at TIMESTAMP NOT NULL,
		ride_length TIME NOT NULL,
		day_of_week SMALLINT NOT NULL,
		season VARCHAR(6) NOT NULL,
		FOREIGN KEY(ride_id) REFERENCES ride_types(ride_id)
	);