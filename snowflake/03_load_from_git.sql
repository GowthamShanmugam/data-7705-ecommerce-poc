-- Load the CSV that lives in Git into RAW.ORDERS.
-- This is the stand-in for Fivetran until the Google Sheets connector is running.
-- Ticket acceptance still wants Fivetran; see README.

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;
USE DATABASE SNOWFLAKE_LEARNING_DB;

ALTER GIT REPOSITORY ecommerce_poc_git FETCH;

COPY INTO RAW.ORDERS
  FROM @ecommerce_poc_git/branches/main/data/orders.csv
  FILE_FORMAT = (
    TYPE = CSV
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    EMPTY_FIELD_AS_NULL = TRUE
  )
  ON_ERROR = 'CONTINUE';

SELECT COUNT(*) AS RAW_ROW_COUNT FROM RAW.ORDERS;
SELECT * FROM RAW.ORDERS LIMIT 5;
