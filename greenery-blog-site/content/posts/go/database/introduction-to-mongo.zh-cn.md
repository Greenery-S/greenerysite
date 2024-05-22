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

## 1 简介

{{< image src="/images/introduction-to-mongo-compare-to-mysql.png" alt="compare-to-mysql" position="center" style="border-radius: 0px; width: 80%;" >}}

- Mongo是一个面向文档存储的数据库，它跟关系型数据库的概念对比如下。
- Mongo最大的特点是模式自由，即你可以将结构完全不同的文档存储同一个集合中。特别适合于业务初期，表字段不稳定的时候。
- 相比于MySQL，Mongo更适合存储大尺寸、低价值的数据，大文档的读写性能比MySQL好。

## 2 语法

```sh
use test;  切换到test库，如果没有则（创建集合时）会自动创建

show collections  查看库里有哪些集合
db.createCollection("student");  创建collection

db.createUser({user: "tester",pwd: "123456", roles: [{role: "dbAdmin", db: "test"}]});创建用户
用刚创建的tester用户身份登录：
mongo --port 27017 -u "tester" -p "123456" --authenticationDatabase "test"

db.student.createIndex({name:1,unique:1})在name上创建唯一索引,1表示升序，-1表示降序
db.student.dropIndex(" name_1_unique_1 ")  删除索引
db.student.getIndexes()  查看索引

db.student.insertOne({name:"张三",city:"北京"});    插入一条记录
db.student.insertMany([{name:"张三",city:"北京"},{name:"李四",gender:"女"}])      插入多条记录

db.student.find({name:"张三"});     查找满足条件的记录          
db.student.find({});    查看集合里的全部内容

db.student.updateOne({name:"张三"},{$set:{gender:"女"}})      更新一条记录
db.student.updateMany({name:"张三"},{$set:{gender:"女"}})      更新满足条件的所有记录
 
db.student.deleteOne({name:"张三"});     db.student.deleteMany({name:"张三"});         删除记录
db.student.drop()   删除集合
```
## 3 Go操作Mongo

### 连接
```go
func main() {
	ctx := context.Background()
	option := options.Client().ApplyURI("mongodb://127.0.0.1:27017").
		SetConnectTimeout(time.Second). //连接超时时长
		//AuthSource代表Database
		SetAuth(options.Credential{Username: "tester", Password: "123456", AuthSource: "test"})
	client, err := mongo.Connect(ctx, option)
	CheckError(err)
	err = client.Ping(ctx, nil) //Connect没有返回error并不代表连接成功，ping成功才代表连接成功
	CheckError(err)
	defer client.Disconnect(ctx) //释放链接
	// ...
}
```

### CURD

见code.



