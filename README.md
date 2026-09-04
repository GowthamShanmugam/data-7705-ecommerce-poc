# DATA-7705 local POC

Onboarding story: public e-commerce data → Snowflake → dbt clean + sales metrics.

This is a **laptop + Snowflake trial** POC. It is not a Dataverse product. Same ideas, smaller:

| Dataverse | This POC |
|---|---|
| Fivetran writes `fivetran_db` | Git CSV (or Fivetran later) writes `SNOWFLAKE_LEARNING_DB.RAW` |
| Operator creates `{product}_db.marts` | SQL creates schemas `RAW` and `MARTS` |
| `*-dbt` repo | `dbt/` in this repo |
| GitLab + Operator CRs | Snowflake Git clone ([docs](https://docs.snowflake.com/en/developer-guide/git/git-setting-up)) |

Ticket: [DATA-7705](https://redhat.atlassian.net/browse/DATA-7705)

---

## 0. Snowflake CLI

You already have a trial account. Test:

```bash
export SNOWFLAKE_PASSWORD='your-trial-password'
snow --config-file="$HOME/snowflake/config.toml" connection test
```

Do not keep the password in `config.toml` if you can use the env var instead.

---

## 1. Push this repo to GitHub

Snowflake Git needs a remote HTTPS URL.

```bash
cd ~/data-7705-ecommerce-poc
# create an empty GitHub repo named data-7705-ecommerce-poc, then:
git add .
git commit -m "DATA-7705: ecommerce POC with Snowflake Git and dbt"
git remote add origin https://github.com/<you>/data-7705-ecommerce-poc.git
git push -u origin main
```

Create a GitHub **fine-grained or classic PAT** with read access to that repo.

---

## 2. Connect Git to Snowflake

In a Snowflake worksheet (or `snow sql`), open `snowflake/01_git_setup.sql`.

Replace:

- `<github-username>`
- `<github-personal-access-token>`
- the `ORIGIN` URL

Run the file. Then:

```sql
ALTER GIT REPOSITORY ecommerce_poc_git FETCH;
LS @ecommerce_poc_git/branches/main;
```

You should see `data/orders.csv` and the `snowflake/` scripts.

---

## 3. Create rooms and load raw data

```sql
EXECUTE IMMEDIATE FROM @ecommerce_poc_git/branches/main/snowflake/02_create_objects.sql;
EXECUTE IMMEDIATE FROM @ecommerce_poc_git/branches/main/snowflake/03_load_from_git.sql;
```

`RAW.ORDERS` is the messy copy (spaces, mixed-case category, cancelled rows). That stands in for Fivetran so dbt can run today.

---

## 4. dbt: clean + metrics

```bash
cd ~/data-7705-ecommerce-poc/dbt
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-snowflake
cp profiles.yml.example profiles.yml
export SNOWFLAKE_PASSWORD='your-trial-password'
dbt debug
dbt run
```

What dbt writes into `MARTS`:

- `STG_ORDERS` — trimmed names, `Initcap` category, date typed, line amount
- `SALES_BY_CATEGORY` — total sales by category (completed only)
- `ORDERS_PER_CUSTOMER` — orders and spend per customer
- `SALES_TREND` — sales by month

---

## 5. Query in Snowflake (ticket AC)

Run `snowflake/04_query_metrics.sql`. You should see category totals, top customers, and a monthly trend.

---

## 6. Fivetran (still required by the ticket)

Git load is a shortcut. Acceptance criteria still say Fivetran.

1. Create a [Fivetran trial](https://fivetran.com/docs/getting-started/quickstart).
2. Destination = this Snowflake trial (`RAW` schema).
3. Upload `data/orders.csv` to a Google Sheet.
4. Connector: [Google Sheets](https://fivetran.com/docs/connectors/files/google-sheets/google-sheets-setup-guide).
5. Sync. Confirm rows in the Fivetran schema (often `GOOGLE_SHEETS` or similar).
6. Point dbt `models/staging/_sources.yml` at that schema, then `dbt run` again.

Until Fivetran is connected, keep using `RAW.ORDERS` from Git.

---

## Folder map

```text
data/orders.csv              sample e-commerce rows (intentionally messy)
snowflake/01_git_setup.sql   API integration + GIT REPOSITORY
snowflake/02_create_objects.sql
snowflake/03_load_from_git.sql
snowflake/04_query_metrics.sql
dbt/models/staging/          clean
dbt/models/marts/            sales metrics
```
