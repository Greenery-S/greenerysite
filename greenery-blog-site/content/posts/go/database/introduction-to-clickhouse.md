---
title: "Introduction to Clickhouse"
date: 2024-05-22T15:08:40+08:00
draft: false
toc: false
images:
tags:
  - clickhouse
  - OLAP
  - database
  - big data
  - grafana
categories:
  - go
  - go-basics
  - go-basics-database
---

# ClickHouse

> code: https://github.com/Greenery-S/go-database/tree/master/clickhouse

## 1 Introduction

ClickHouse is a columnar database management system (DBMS) for online analytical processing (OLAP).

In traditional row-based database systems (MySQL, SQL Server), data in the same row is always physically stored together. In columnar database systems (ClickHouse, HBase, Druid), data from the same column is stored together.

Key characteristics of OLAP scenarios (statistical analysis based on event tracking data):
1. The vast majority are read requests, and data added to the database cannot be modified.
2. Wide tables, meaning each table contains a large number of columns.
3. For reads, a significant number of rows are extracted from the database, but only a small portion of the columns.
4. Relatively few queries (typically hundreds or fewer per second per server).
5. For simple queries, a latency of about 50 milliseconds is acceptable.
6. Data in columns is relatively small: numbers and short strings (e.g., 60 bytes per URL).
7. High throughput is required when processing a single query (up to billions of rows per second per server).
8. Transactions are not necessary.

## 2 Usage

Its SQL syntax is similar to MySQL, but there are some differences.

Creating a database and table:
```sql
create database test;

-- json type is experimental feature
set allow_experimental_object_type = 1;

CREATE TABLE test.user
(
    user_id     UInt32 comment 'User ID',       -- User ID
    name        String comment 'User Name',     -- User Name
    create_time DateTime comment 'Registration Time', -- Registration Time
    extra       Json comment 'Additional Info'  -- Additional Info, json can freely extend fields
) ENGINE = MergeTree()
      PRIMARY KEY (create_time);
```

Querying data:
```sql
WITH
    toDateTime('2023-09-01', 'UTC') AS begin_day,
    toDateTime('2023-09-08', 'UTC') AS end_day
SELECT toDate(create_time) AS date,
       uniq(user_id)       AS `Number of Registered Users`
FROM test.user
WHERE (create_time >= begin_day)
  AND (create_time < end_day)
GROUP BY date
ORDER BY date;
```

## 3 Go SDK
See code.

## 4 Creating Dashboards
Generate business reports based on ClickHouse and Grafana.

{{< image src="/images/introduction-to-clickhouse-dashboard.png" alt="dashboard" position="center" style="border-radius: 0px; width: 100%;" >}}