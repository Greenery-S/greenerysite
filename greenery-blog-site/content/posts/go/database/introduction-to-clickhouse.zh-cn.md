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

## 1 简介

ClickHouse是一个用于联机分析（OLAP）的列式数据库管理系统（DBMS）。

在传统的行式数据库系统（MySQL、SQL Server）中，处于同一行中的数据总是被物理的存储在一起。在列式数据库系统（ClickHouse、HBase、Druid）中，来自同一列的数据被存储在一起。

OLAP场景的关键特征 (基于埋点数据进行业务的统计分析):
1. 绝大多数是读请求，已添加到数据库的数据不能修改
2. 宽表，即每个表包含着大量的列
3. 对于读取，从数据库中提取相当多的行，但只提取列的一小部分 
4. 查询相对较少（通常每台服务器每秒查询数百次或更少）
5. 对于简单查询，允许延迟大约50毫秒
6. 列中的数据相对较小：数字和短字符串（例如，每个URL 60个字节）
7. 处理单个查询时需要高吞吐量（每台服务器每秒可达数十亿行）
8. 事务不是必须的

## 2 使用方法

它的SQL语法和MySQL类似，但是有一些不同之处。

创建数据库,表：
```sql
create database test;
       
-- json type is experimental feature
set allow_experimental_object_type = 1; 

CREATE TABLE test.user
(
    user_id     UInt32 comment '用户ID',     -- 用户ID
    name        String comment '用户姓名',   -- 用户名
    create_time DateTime comment '注册时间', -- 注册时间
    extra       Json comment '附加信息'      -- 附加信息,json可自由扩充字段
) ENGINE = MergeTree()
      PRIMARY KEY (create_time);
```

查询数据:
```sql
WITH
    toDateTime('2023-09-01', 'UTC') AS begin_day,
    toDateTime('2023-09-08', 'UTC') AS end_day
SELECT toDate(create_time) AS date,
       uniq(user_id)       AS `注册用户数`
FROM test.user
WHERE (create_time >= begin_day)
  AND (create_time < end_day)
GROUP BY date
ORDER BY date;
```

## 3 Go sdk
见code.

## 4 制作dashboard

基于Clickhouse+grafana生成业务报表.

{{< image src="/images/introduction-to-clickhouse-dashboard.png" alt="dashboard" position="center" style="border-radius: 0px; width: 100%;" >}}