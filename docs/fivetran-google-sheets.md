# Fivetran path for DATA-7705

Use this after the Git + dbt path works.

## Why

The story says: e-commerce dataset is successfully replicated into a designated Snowflake schema **with Fivetran**.

Google Sheets is the connector the onboarding story links.

## Steps

1. Sign up at Fivetran (free trial).
2. Add a Snowflake destination:
   - account: `BRZDEJI-QL84586`
   - user: your trial user
   - role: `ACCOUNTADMIN` (trial only)
   - warehouse: `SNOWFLAKE_LEARNING_WH`
   - database: `SNOWFLAKE_LEARNING_DB`
3. Copy `data/orders.csv` into a Google Sheet. First row = headers.
4. In Fivetran, add **Google Sheets** connector. Pick that sheet. Schema prefix something like `google_sheets`.
5. Start the sync. In Snowflake: `SHOW TABLES IN SCHEMA SNOWFLAKE_LEARNING_DB.<fivetran_schema>;`
6. Edit `dbt/models/staging/_sources.yml`:
   - `schema:` → the Fivetran schema
   - `tables: - name:` → the synced table name
7. `dbt run` again.

Same dbt models. Different raw source. That is the Dataverse idea: Fivetran fills raw, dbt fills marts.
