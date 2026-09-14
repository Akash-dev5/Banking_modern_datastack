#🏦 Banking Modern Datastack

**An event-driven banking data platform built around SQL, Snowflake and dbt.** PostgreSQL CDC is captured with Debezium/Kafka, landed in Amazon S3, loaded into Snowflake through Airflow, and transformed into analytics-ready models with dbt.

**Supporting engineering:** PostgreSQL · Debezium · Kafka · Python · S3 · SQS · Airflow · Docker · GitHub Actions · EC2


##Why this project?
I built this project to demonstrate how a modern warehouse-oriented data pipeline works from source to analytics-ready data.

The **core focus is the warehouse and transformation layer:**

SQL-based transformations
Snowflake warehouse development
dbt staging, dimension and fact models
Incremental processing
dbt snapshots and historical tracking
Data modeling for customers, accounts and transactions

The CDC, messaging, cloud-storage, orchestration and CI/CD components are supporting layers that make the warehouse workflow realistic and end-to-end.


## Architecture
**End-to-end flow**

PostgreSQL
    │
    ▼
Debezium → Kafka
    │
    ▼
Python Consumer
    │
    ▼
Amazon S3
    │
    ▼
Amazon SQS
    │
    ▼
Airflow Triggerer (EC2)
    │
    ▼
S3 → Snowflake
    │
    ▼
Snowflake Raw Tables
    │
    ▼
dbt: Staging → Dimensions/Facts → Snapshots → Analytical Models


## Deployment boundary



Design choice: Kafka, Debezium and the consumer remain local for this portfolio deployment. Only Airflow is deployed to EC2 to keep the cloud footprint lightweight while still demonstrating CI/CD and production-style orchestration.


## SQL, Snowflake & dbt — Core Focus

## Snowflake

Snowflake is the central analytical warehouse.

The implemented warehouse flow:

CDC changes are captured from PostgreSQL.
The consumer batches CDC records and writes Parquet files to S3.
S3 notifications are delivered through SQS.
Airflow loads the batch into Snowflake.
dbt transforms the Snowflake data into reusable analytical models.

The Snowflake work includes:
S3 → Snowflake ingestion
Snowflake stages and external storage integration
Raw/staging warehouse structures
SQL transformations
Incremental loading
Duplicate-data handling
Analytical data modeling

## dbt

The dbt project currently contains:

**7 models**
**2 snapshots**
**3 sources**
Staging models
Customer and account dimensions
Transaction fact model
Incremental transaction processing
Snapshot-based historical tracking
ref()-based model dependencies

The project uses snapshots to preserve historical versions of source records and an incremental model for transaction processing.


## Example SQL

select
    account_id,
    customer_id,
    account_type,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('accounts_snapshot') }}
where dbt_valid_to is null


## Data Modeling

The dbt layer turns raw CDC data into warehouse-oriented models:

Raw CDC Tables
      │
      ├───────────────┐
      ▼               ▼
dbt Staging       Snapshots
      │               │
      ▼               ▼
dim_customers     dim_accounts
      │               │
      └───────┬───────┘
              ▼
      fct_transactions
              │
              ▼
      obt_transactions


## Modeling concepts demonstrated

Staging → dimension/fact transformations
Incremental models
Snapshot history
SCD Type 2-style historical tracking
Source-to-model dependencies
Reusable warehouse transformations
Analytics-ready outputs


## End-to-End Data Flow

### 1. Capture

PostgreSQL acts as the operational source.

Debezium captures database changes and publishes them to Kafka topics.

### 2. Ingest

The Python consumer reads the CDC topics and buffers records by entity.

When the configured batch targets are reached, the consumer writes Parquet files to S3 and creates a _batch_complete marker.

### 3. Event

S3 object-created notifications are delivered to SQS.

The completion marker provides a clear downstream signal that the batch is ready for processing.

### 4. Orchestrate

The Airflow Triggerer watches the SQS queue through an SqsSensorTrigger.

The batch event triggers the S3-loading workflow through an Airflow asset.

### 5. Load

s3_stg_to_snowflake loads customers, accounts and transactions into Snowflake.

### 6. Transform

snowflake_raw_table_loaded triggers banking_dbt_pipeline.

The dbt workflow runs the staging models, snapshots, dimensions, fact model and downstream analytical models.
