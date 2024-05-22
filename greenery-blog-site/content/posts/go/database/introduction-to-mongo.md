---
title: "Introduction to Mongo"
date: 2024-05-22T01:23:35+08:00
draft: false
toc: false
images:
tags:
  - mongo
  - mongodb
  - go-mongo
categories:
  - go
  - go-basics
  - go-basics-database
---

# MongoDB
> code: https://github.com/Greenery-S/go-database/tree/master/mongo

## 1 Introduction

{{< image src="/images/introduction-to-mongo-compare-to-mysql.png" alt="compare-to-mysql" position="center" style="border-radius: 0px; width: 80%;" >}}

- Mongo is a document-oriented database, and it contrasts with relational databases as follows.
- Mongo's greatest feature is its schema flexibility, meaning you can store documents with completely different structures in the same collection. This is especially useful in the early stages of a project when the table fields are not yet stable.
- Compared to MySQL, Mongo is better suited for storing large, low-value data. The read and write performance for large documents is better in Mongo than in MySQL.

## 2 Syntax

```sh
use test;  # Switch to the test database, which will be automatically created if it doesn't exist when a collection is created

show collections  # View the collections in the database
db.createCollection("student");  # Create a collection

db.createUser({user: "tester",pwd: "123456", roles: [{role: "dbAdmin", db: "test"}]}); # Create a user
# Log in with the newly created tester user:
mongo --port 27017 -u "tester" -p "123456" --authenticationDatabase "test"

db.student.createIndex({name:1,unique:1}) # Create a unique index on the name field, 1 for ascending order, -1 for descending order
db.student.dropIndex("name_1_unique_1")  # Delete the index
db.student.getIndexes()  # View the indexes

db.student.insertOne({name:"张三",city:"北京"});  # Insert a single record
db.student.insertMany([{name:"张三",city:"北京"},{name:"李四",gender:"女"}]);  # Insert multiple records

db.student.find({name:"张三"});  # Find records that match the condition
db.student.find({});  # View all records in the collection

db.student.updateOne({name:"张三"},{$set:{gender:"女"}});  # Update a single record
db.student.updateMany({name:"张三"},{$set:{gender:"女"}});  # Update all records that match the condition

db.student.deleteOne({name:"张三"});  db.student.deleteMany({name:"张三"});  # Delete records
db.student.drop();  # Drop the collection
```

## 3 Using Mongo with Go

### Connection

```go
func main() {
    ctx := context.Background()
    option := options.Client().ApplyURI("mongodb://127.0.0.1:27017").
        SetConnectTimeout(time.Second). // Connection timeout duration
        // AuthSource represents the Database
        SetAuth(options.Credential{Username: "tester", Password: "123456", AuthSource: "test"})
    client, err := mongo.Connect(ctx, option)
    CheckError(err)
    err = client.Ping(ctx, nil) // A successful ping indicates a successful connection, not just the absence of an error from Connect
    CheckError(err)
    defer client.Disconnect(ctx) // Release the connection
    // ...
}
```

### CRUD Operations

See the code repository for examples.