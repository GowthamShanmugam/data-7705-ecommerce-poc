-- Creates the two Snowflake rooms for this POC.
-- RAW  = messy copy (what Fivetran would write)
-- MARTS = clean tables (what dbt writes)
--
-- After Git is connected:
--   ALTER GIT REPOSITORY ecommerce_poc_git FETCH;
--   EXECUTE IMMEDIATE FROM @ecommerce_poc_git/branches/main/snowflake/02_create_objects.sql;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;
USE DATABASE SNOWFLAKE_LEARNING_DB;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS MARTS;

CREATE OR REPLACE TABLE RAW.ORDERS (
  ORDER_ID        NUMBER,
  ORDER_DATE      VARCHAR,
  CUSTOMER_ID     VARCHAR,
  CUSTOMER_NAME   VARCHAR,
  CATEGORY        VARCHAR,
  PRODUCT         VARCHAR,
  QUANTITY        NUMBER,
  UNIT_PRICE      NUMBER(10, 2),
  STATUS          VARCHAR
);
