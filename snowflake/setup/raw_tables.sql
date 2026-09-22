USE DATABASE BANKING_PROJECT;
USE SCHEMA RAW;


-- =========================================================
-- CUSTOMERS
-- =========================================================

CREATE TABLE IF NOT EXISTS CUSTOMERS (
    v VARIANT,
    INGESTED_AT TIMESTAMP_TZ);


-- =========================================================
-- ACCOUNTS
-- =========================================================

CREATE TABLE IF NOT EXISTS ACCOUNTS (
    v VARIANT,
    INGESTED_AT TIMESTAMP_TZ);


-- =========================================================
-- TRANSACTIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS TRANSACTIONS (
    v VARIANT,
    INGESTED_AT TIMESTAMP_TZ);