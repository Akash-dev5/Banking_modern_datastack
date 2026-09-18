# 🏦 Banking Modern Datastack

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?logo=snowflake&logoColor=white)
![DBT](https://img.shields.io/badge/dbt-FF694B?logo=dbt&logoColor=white)
![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?logo=apacheairflow&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-231F20?logo=apachekafka&logoColor=white)
![Debezium](https://img.shields.io/badge/Debezium-EF3B2D?logo=apache&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?logo=git&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-000000?logo=githubactions&logoColor=white)

# Banking Modern Datastack

[![CI](https://github.com/Akash-dev5/banking_datastack/actions/workflows/ci.yml/badge.svg)](https://github.com/Akash-dev5/banking_datastack/actions/workflows/ci.yml)
![Snowflake](https://img.shields.io/badge/Snowflake-Data_Warehouse-29B5E8?logo=snowflake&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-Transformations-FF694B?logo=dbt&logoColor=white)
![Apache Airflow](https://img.shields.io/badge/Airflow-Orchestration-017CEE?logo=apacheairflow&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20SQS%20%7C%20EC2-FF9900?logo=amazonaws&logoColor=white)

> **An event-driven banking data platform with a strong focus on SQL, Snowflake, dbt, and data modeling.**  
> PostgreSQL changes are captured with Debezium and Kafka, landed in Amazon S3, loaded into Snowflake through Airflow, and transformed into analytics-ready models with dbt.

**Primary focus:** `SQL` · `Snowflake` · `dbt` · `Data Modeling`

**Supporting engineering:** `PostgreSQL` · `Debezium` · `Kafka` · `Python` · `S3` · `SQS` · `Airflow` · `Docker` · `GitHub Actions` · `EC2`

---

## Architecture

![Banking Modern Datastack architecture](architecture-overview.png)

The project is split between local development, AWS services, Snowflake, and an Airflow environment running on EC2.

### Data Flow

```text
PostgreSQL
    ↓
Debezium → Kafka → Python Consumer
    ↓
Amazon S3 → Amazon SQS
    ↓
Airflow on EC2
    ↓
Snowflake
    ↓
dbt
    ↓
Analytics-ready models
```

### Deployment Boundary

| Layer | Where it runs | Purpose |
|---|---|---|
| PostgreSQL | Local | Operational source |
| Debezium + Kafka | Local | CDC and event streaming |
| Python consumer | Local | Batch CDC data and upload Parquet to S3 |
| S3 + SQS | AWS | Cloud storage and event notification |
| Airflow | EC2 | Event-driven orchestration |
| Snowflake | Cloud | Data warehouse |
| dbt | Airflow/dbt environment | SQL transformations and modeling |
| GitHub Actions + GHCR | GitHub | CI/CD and image publishing |

---

## SQL, Snowflake & dbt

The warehouse and transformation layer is the main focus of this project.

### Snowflake

The project uses Snowflake as the central warehouse for:

- Raw and staging data
- SQL-based transformations
- Incremental loading
- Analytical tables for customers, accounts, and transactions

### dbt

The dbt project currently contains:

- **7 models**
- **2 snapshots**
- **3 sources**
- Staging models
- Dimension and fact models
- Incremental transaction processing
- Snapshot-based historical tracking

A simplified example from the account history layer:

```sql
select
    account_id,
    customer_id,
    account_type,
    dbt_valid_from,
    dbt_valid_to
from {{ ref('accounts_snapshot') }}
where dbt_valid_to is null
```

This returns the current version of each account from the snapshot history.

---

## End-to-End Flow

1. **Capture** — PostgreSQL changes are captured by Debezium and published to Kafka.
2. **Ingest** — The Python consumer batches CDC records and uploads Parquet files to S3.
3. **Trigger** — S3 events are delivered through SQS and used to trigger the Airflow workflow.
4. **Load** — Airflow loads the completed batch from S3 into Snowflake.
5. **Transform** — The Snowflake load triggers the dbt pipeline.
6. **Model** — dbt builds staging, dimensions, facts, snapshots, and downstream analytical models.

---

## Airflow & Orchestration

Airflow runs on EC2 using a lightweight production-style setup with:

- API Server
- Scheduler
- DAG Processor
- Triggerer
- PostgreSQL metadata database

| DAG | Purpose |
|---|---|
| `s3_stg_to_snowflake` | Load S3 batch data into Snowflake |
| `banking_dbt_pipeline` | Run the dbt transformation layer |

The workflows use Airflow assets to connect the completed Snowflake load with the downstream dbt pipeline.

---

## CI/CD

GitHub Actions handles validation and deployment of the Airflow environment.

**CI**

- Validates Python dependencies and Airflow DAGs
- Runs `dbt parse`
- Validates the Airflow database setup
- Builds the Airflow Docker image

**CD**

```text
GitHub Actions → GHCR → EC2 → Airflow
```

The Airflow image is published with both `latest` and the Git commit SHA, so a deployment can be traced back to the corresponding revision.

---

## Validation

The following screenshots show the main parts of the working pipeline and deployment.

### 1. dbt Transformation Pipeline

![Successful dbt transformation pipeline](01-dbt-success.png)

### 2. S3 → Snowflake Load

![Successful S3 to Snowflake load](02-s3-to-snowflake-success.png)

### 3. Airflow Running on EC2

![Airflow production stack on EC2](03-ec2-airflow-stack.png)

### 4. CI Workflow

![Successful CI workflow](04-ci-success.png)

### 5. CD Deployment

![Successful CD deployment](05-cd-success.png)

### 6. GitHub Container Registry

![Airflow image published to GHCR](06-ghcr-image.png)

---

## Repository Structure

```text
banking_datastack/
├── .github/workflows/
│   ├── ci.yml
│   └── cd.yml
├── airflow/
│   ├── dags/
│   ├── plugins/
│   └── Dockerfile
├── banking_dbt/
│   ├── models/
│   ├── snapshots/
│   ├── seeds/
│   ├── tests/
│   └── dbt_project.yml
├── cdc/
│   └── debezium/
├── postgres/
├── services/
│   ├── consumer/
│   └── data_generator/
├── snowflake/
│   └── setup/
├── deploy/
│   ├── docker-compose.prod.yml
│   └── ec2-deploy.sh
├── docker-compose.yml
├── requirements.txt
└── README.md
```

---

## Running Locally

The local environment contains the source and CDC components:

- PostgreSQL
- Debezium / Kafka Connect
- Kafka
- Python consumer
- Banking data generator
- Kafka UI

Airflow is deployed separately to EC2.

Snowflake setup scripts are kept under `snowflake/setup/`, while the transformation logic lives under `banking_dbt/`.

---

## Security

- Secrets are supplied through environment variables or GitHub Secrets.
- AWS and Snowflake credentials are not committed to the repository.
- The production `.env` remains on the EC2 instance.
- No production credentials are included in the project.

---

## Author

**Akash Verma**

`SQL` · `Snowflake` · `dbt` · `Data Engineering`

[GitHub](https://github.com/Akash-dev5)
