COPY ride_types FROM
'/.../bikeshare-analysis/processed-data/csv-files-for-import/ride_types.csv' CSV HEADER;

COPY ride_times FROM
'/.../bikeshare-analysis/processed-data/csv-files-for-import/ride_times.csv' CSV HEADER;

COPY ride_dates FROM
'/.../bikeshare-analysis/processed-data/csv-files-for-import/ride_dates.csv' CSV HEADER;
