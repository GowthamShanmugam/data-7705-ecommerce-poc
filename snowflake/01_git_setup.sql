-- DATA-7705: connect this Git repo to Snowflake.
-- Docs: https://docs.snowflake.com/en/developer-guide/git/git-setting-up
--
-- Do this after you push the repo to GitHub (HTTPS URL).
-- Create a GitHub personal access token with repo read access.
-- Do not put the token in git. Paste it only in the Snowflake worksheet.

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE SNOWFLAKE_LEARNING_WH;
USE DATABASE SNOWFLAKE_LEARNING_DB;
USE SCHEMA PUBLIC;

-- 1) Secret = GitHub username + PAT
CREATE OR REPLACE SECRET ecommerce_git_secret
  TYPE = PASSWORD
  USERNAME = '<github-username>'
  PASSWORD = '<github-personal-access-token>';

-- 2) API integration = which Git host Snowflake may call
CREATE OR REPLACE API INTEGRATION ecommerce_git_api
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/<github-username>/')
  ALLOWED_AUTHENTICATION_SECRETS = (ecommerce_git_secret)
  ENABLED = TRUE;

-- 3) Git clone object inside Snowflake
CREATE OR REPLACE GIT REPOSITORY ecommerce_poc_git
  API_INTEGRATION = ecommerce_git_api
  GIT_CREDENTIALS = ecommerce_git_secret
  ORIGIN = 'https://github.com/<github-username>/data-7705-ecommerce-poc.git';

-- 4) Pull files, then list them
ALTER GIT REPOSITORY ecommerce_poc_git FETCH;
LS @ecommerce_poc_git/branches/main;
