-- SQL file for Citibike Trips with Weather Data

SELECT
  TRI.usertype,
  ZIPSTART.zip_code AS zip_code_start,
  ZIPSTARTNAME.borough AS borough_start,
  ZIPSTARTNAME.neighborhood AS neighborhood_start,
  ZIPEND.zip_code AS zip_code_end,
  ZIPENDNAME.borough AS borough_end,
  ZIPENDNAME.neighborhood AS neighborhood_end,
  -- Adding 5 years to start and stop time to simulate recent data
  DATE_ADD(DATE(TRI.starttime), INTERVAL 5 YEAR) AS start_day,
  DATE_ADD(DATE(TRI.stoptime), INTERVAL 5 YEAR) AS stop_day,
  WEA.temp AS day_mean_temperature, -- Mean temperature
  WEA.wdsp AS day_mean_wind_speed, -- Mean wind speed
  WEA.prcp AS day_total_precipitation, -- Total precipitation
  -- Grouping trips into 10-minute intervals
  ROUND(CAST(TRI.tripduration / 60 AS INT), -1) AS trip_minutes,
  COUNT(TRI.bikeid) AS trip_count
FROM
  citibike_trips AS TRI
INNER JOIN
  geo_us_boundaries_zip_codes AS ZIPSTART
  ON ST_WITHIN(
    ST_POINT(TRI.start_station_longitude, TRI.start_station_latitude),
    ZIPSTART.zip_code_geom)
INNER JOIN
  geo_us_boundaries_zip_codes AS ZIPEND
  ON ST_WITHIN(
    ST_POINT(TRI.end_station_longitude, TRI.end_station_latitude),
    ZIPEND.zip_code_geom)
INNER JOIN
  noaa_gsod AS WEA
  ON PARSE_DATE('%Y%m%d', CONCAT(WEA.year, WEA.mo, WEA.da)) = DATE(TRI.starttime)
INNER JOIN
  cyclistics_zip_codes AS ZIPSTARTNAME
  ON ZIPSTART.zip_code = CAST(ZIPSTARTNAME.zip AS VARCHAR)
INNER JOIN
  cyclistics_zip_codes AS ZIPENDNAME
  ON ZIPEND.zip_code = CAST(ZIPENDNAME.zip AS VARCHAR)
WHERE
  WEA.wban = '94728' -- NEW YORK CENTRAL PARK weather station
  AND EXTRACT(YEAR FROM DATE(TRI.starttime)) BETWEEN 2014 AND 2015
GROUP BY
  TRI.usertype,
  ZIPSTART.zip_code,
  ZIPSTARTNAME.borough,
  ZIPSTARTNAME.neighborhood,
  ZIPEND.zip_code,
  ZIPENDNAME.borough,
  ZIPENDNAME.neighborhood,
  start_day,
  stop_day,
  WEA.temp,
  WEA.wdsp,
  WEA.prcp,
  trip_minutes;
