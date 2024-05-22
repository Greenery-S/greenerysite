---
title: "Mysql Optimization"
date: 2024-05-19T21:16:35+08:00
draft: false
toc: false
images:
tags:
  - database
  - mysql
  - optimization
categories:  
  - go
  - go-basics
  - go-basics-database
---
# MySQL性能调优
> code: https://github.com/Greenery-S/go-database/tree/master/mysql

# 实战建议

- 写sql时一律使用小写
- 建表时先判断表是否已存在  `if not exists`
- 所有的列和表都加`comment`
- 字符串长度比较短时尽量使用`char`，定长有利于内存对齐，读写性能更好，而`varchar`字段频繁修改时容易产生内存碎片

- 满足需求的前提下尽量使用短的数据类型，如`tinyint` vs `in`t, `float` vs `double`, `date` vs `datetime`

```sql
CREATE TABLE if not exists `student` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键自增id',
  `name` char(10) NOT NULL COMMENT '姓名',
  `province` char(6) NOT NULL COMMENT '省',
  `city` char(10) NOT NULL COMMENT '城市',
  `addr` varchar(100) DEFAULT '' COMMENT '地址',
  `score` float NOT NULL DEFAULT '0' COMMENT '考试成绩',
  `enrollment` date NOT NULL COMMENT '入学时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_location` (`province`,`city`)
) ENGINE=InnoDB AUTO_INCREMENT=100020 DEFAULT CHARSET=utf8 COMMENT='学员基本信息'
```

## 2 null

- `default null`有别于`default ''`和`default 0`

- `is null`, `is not null`有别于`!= ''`, `!=0`

- 尽量设为`not null`

    - 有些DB索引列不允许包含null
    - 对含有null的列进行统计，结果可能不符合预期

    - null值有时候会严重拖慢系统性能

## 3 规避慢查询 (e.g. >1s)

- 大部分的**慢查询**都是因为**没有正确地使用索引**
- 不要**过多地创建索引**，否则**写入会变慢**
- 绝大部分情况使用**默认的InnoDB**引擎，不要使用MyISAM引擎
- 不要select *，**只select你需要的列**
- 尽量用**in代替or**，or的效率没有in高
- **in的元素个数不要太多，一般300到500**
- **不要使用模型查询like，模糊查询不能利用索引**
- **如果确定结果只有一条，则使用limit 1，停止全表扫描**
- **分页查询limit m,n会检索前m+n行，只是返回后n行，通常用id>x来代替这种分页方式**
- **批量操作时最好一条sql语句搞定；其次打包成一个事务，一次性提交，高并发情况下减少对共享资源的争用**
- 避免使用大事务，用短小的事务，减少锁等待和竞争
- 不要一次查询或更新太多数据，尽量控制在1000条左右
- 不要使用连表操作，join逻辑在业务代码里完成
- 不用 MYSQL 内置的函数，因为内置函数不会建立查询缓存，复杂的计算逻辑放到自己的代码里去做

## 4 B+树

1. B即Balance，对于m叉树每个节点上最多有m个数据，最少有m/2个数据（根节点除外）。
1. 叶节点上存储了所有数据，把叶节点链接起来可以顺序遍历所有数据。
1. 每个节点设计成内存页(4K)的整倍数。MySQL的m=1200，**树的前两层放在内存中**。

{{< image src="/images/mysql-optimization-bplustree.png" alt="b+tree" position="center" style="border-radius: 20px; width: 300px;" >}}

## 5 索引

- MySQL索引默认使用B+树
    - why not hashtable? -- 1)全部数据不可能都加载内存;2)不利于范围查找;
- 主键默认会加索引。**按主键构建的B+树里包含所有列的数据**，而**普通索引的B+树里只存储了主键**，还需要再查一次主键对应的B+树（**回表**）
- **联合索引的前缀**同样具有索引的效果
- sql语句前加**explain**可以查看索引使用情况
- 如果MySQL没有选择最优的索引方案，可以在**where前force index (index_name)**

```sql
show create table student
```

{{< image src="/images/mysql-optimization-show-table.png" alt="show-table" position="center" style="border-radius: 10px; width: 100%;" >}}


## 6 覆盖索引

{{< image src="/images/mysql-optimization-cover-index.png" alt="cover-index" position="center" style="border-radius: 10px; width: 300;" >}}

```sql
explain select city from student where name='张三' and province='北京';
explain select city from student force index (idx_location) where name='张三' and province='北京';
```

{{< image src="/images/mysql-optimization-explain-select.png" alt="cover-index" position="center" style="border-radius: 10px; width: 300;" >}}


- 第一个查询需要回表
- **第二个SQL只需要查询city，且刚好命中了(`province`,`city`)这个联合索引，不需要回表，这就是覆盖索引(即命中非主键索引，且不需要回表** ==存疑==
- 覆盖索引在Extra里会显示Using index

## 7 SQL注入攻击

**CASE 1**

- `sql = "select username,password from user where username='" + username + "' and password='" + password + "'"; `
- 变量username和password从前端输入框获取，如果用户输入的username为lily， password为aaa' or '1'='1
- 则完整的sql为select username,password from user where username='lily' and password='aaa' or '1'='1'
- 会返回表里的所有记录，如果记录数大于0就允许登录，则lily的账号被盗

**CASE 2**

- `sql="insert into student (name) values ('"+username+" ') ";`
- 变量username从前端输入框获取，如果用户输入的username为`lily'); drop table student;--‘)`
- 完整sql为insert into student (name) values ('lily'); drop table student;--')
- 通过注释符--屏蔽掉了末尾的')，删除了整个表

#### 防范方法

**总体**

- 前端输入要加正则校验、长度限制
- 对特殊符号(<>&*; '"等)进行转义或编码转换，Go的text/template 包里面的`HTMLEscapeString`函数可以对字符串进行转义处理
- 不要将用户输入直接嵌入到sql语句中，而应该使用**参数化查询接口**，如Prepare、Query、Exec(query string, args ...interface{})
- 使用专业的SQL注入检测工具进行检测，如sqlmap、SQLninja
- **避免网站打印出SQL错误信息**，以防止攻击者利用这些错误信息进行SQL注入
- 没有任何一种方式能防住所有的sql注入，以上方法要结合使用

**Stmt**

- 定义一个sql模板 `stmt, err := db.Prepare("update student set score=score+? where city=?")`

- 多次使用模板:

  ```go
  res, err := stmt.Exec(10, "上海")
  res, err = stmt.Exec(9, "深圳")
  ```

- 不要拼接sql(容易被SQL注入攻击，且利用不上编译优化):  `db.Where(fmt.Sprintf("merchant_id = %s", merchantId))`

```sql
CREATE TABLE if not exists `login` (
                                       `username` varchar(100) DEFAULT NULL,
                                       `password` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

```go
// 登录成功返回true。容易被SQL注入攻击
func LoginUnsafe(db *gorm.DB, name, passwd string) bool {
	var cnt int64
	db.Table("login").Select("*").Where("username='" + name + "' and password='" + passwd + "'").Count(&cnt)
	return cnt > 0
}

// 登录成功返回true。拒绝SQL注入攻击
func LoginSafe(db *gorm.DB, name, passwd string) bool {
	var cnt int64
	db.Table("login").Select("*").Where("username=? and password=?", name, passwd).Count(&cnt)
	return cnt > 0
}
```

```go
func TestLoginUnsafe(t *testing.T) {
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{PrepareStmt: true}) //强行使用PrepareStmt
	if err != nil {
		panic(err)
	}
	if LoginUnsafe(db, "tom", "123456") == false {
		t.Fail()
	}
	if LoginUnsafe(db, "tom", "456789") == true {
		t.Fail()
	}
	// select * from login where username='tom' and password='456789' or '1'='1'
	if LoginUnsafe(db, "tom", "456789' or '1'='1") == false {
		t.Fail()
	}
}

func TestLoginSafe(t *testing.T) {
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{PrepareStmt: true}) //强行使用PrepareStmt
	if err != nil {
		panic(err)
	}
	if LoginSafe(db, "tom", "123456") == false {
		t.Fail()
	}
	if LoginSafe(db, "tom", "456789") == true {
		t.Fail()
	}
	if LoginSafe(db, "tom", "456789' or '1'='1") == true {
		t.Fail()
	}
}
```

**SQL预编译**

- DB执行sql分为3步：
    1. 词法和语义解析
    2. 优化 SQL 语句，制定执行计划
    3. 执行并返回结果

- SQL 预编译技术是指将用户输入用占位符?代替，先对这个模板化的sql进行预编译，实际运行时再将用户输入代入

- 除了可以防止 SQL 注入，还可以对预编译的SQL语句进行缓存，之后的运行就省去了解析优化SQL语句的过程

```go
func BenchmarkQueryWithoutPrepare(b *testing.B) {
	client, err := gorm.Open(mysql.Open(dsn), &gorm.Config{}) //没有指定PrepareStmt
	if err != nil {
		panic(err)
	}
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		LoginUnsafe(client, name, passwd)
	}
}

func BenchmarkQueryWithPrepare(b *testing.B) {
	client, err := gorm.Open(mysql.Open(dsn), &gorm.Config{PrepareStmt: true}) //强行使用PrepareStmt
	if err != nil {
		panic(err)
	}
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		LoginUnsafe(client, name, passwd)
	}
}
```

```shell
> go test ./ -bench=^BenchmarkQueryWith -run=^$ -count=1 -benchmem
goos: darwin
goarch: arm64
pkg: dqq/database/mysql
BenchmarkQueryWithoutPrepare-10             7888            147138 ns/op            3441 B/op         54 allocs/op
BenchmarkQueryWithPrepare-10                8508            130443 ns/op            3458 B/op         55 allocs/op
PASS
```

## 8 分页查询

- 分页查询limit m,n会检索前m+n行，只是返回后n行，通常用`id>x`来代替这种分页方式。
- 全表扫描
    1. 直接select * from table肯定是慢查询，违背了一次查询行数不能太多的原则
    1. 分页查询表面上查询的行数不多，实则是执行了多次方式1
    1. 固定page_size，维护当前查询到在最大id(max_id)，查询时使用`where id>maxid limit page_size`，当查询结果为空时，退出循环

{{< image src="/images/mysql-optimization-pagenate.png" alt="cover-index" position="center" style="border-radius: 10px; width: 300;" >}}

## 9 事务

- 批量操作时最好一条sql语句搞定；其次打包成一个事务，一次性提交，高并发情况下减少对共享资源的争用

```go
const (
	INSERT_COUNT = 100000
)

// 一条一条插入
func InsertOneByOne(db *gorm.DB) {
	begin := time.Now()
	for i := 0; i < INSERT_COUNT; i++ {
		student := Student{Name: "学生" + strconv.Itoa(i), Province: "北京", City: "北京", Score: 38, Enrollment: time.Now()}
		if err := db.Create(&student).Error; err != nil { //注意需要传student的指针
			fmt.Println(err)
			return
		}
	}
	fmt.Println("total", time.Since(begin))
}

// 放在一个事务里插入
func InsertByTransaction1(db *gorm.DB) {
	begin := time.Now()
	tx := db.Begin()
	for i := 0; i < INSERT_COUNT; i++ {
		student := Student{Name: "学生" + strconv.Itoa(i), Province: "北京", City: "北京", Score: 38, Enrollment: time.Now()}
		if err := tx.Create(&student).Error; err != nil {
			fmt.Println(err)
			return
		}
	}
	tx.Commit()
	fmt.Println("total", time.Since(begin))
}

// 一次插入多条，整体再放到一个事务里
func InsertByTransaction2(db *gorm.DB) {
	begin := time.Now()
	tx := db.Begin()
	const BATCH = 100 // 一条SQL语句插入多条
	for i := 0; i < INSERT_COUNT; i += BATCH {
		students := make([]Student, 0, BATCH)
		for j := 0; j < BATCH; j++ {
			student := Student{Name: "学生" + strconv.Itoa(i+j), Province: "北京", City: "北京", Score: 38, Enrollment: time.Now()}
			students = append(students, student)
		}
		if err := tx.Create(&students).Error; err != nil {
			fmt.Println(err)
			return
		}
	}
	tx.Commit()
	fmt.Println("total", time.Since(begin))
}
```

```sh
=== RUN   TestInsertOneByOne
...
total 1m55.652681166s
--- PASS: TestInsertOneByOne (116.20s)

=== RUN   TestInsertByTransaction1
...
total 27.29299825s
--- PASS: TestInsertByTransaction1 (27.91s)

=== RUN   TestInsertByTransaction2
...
total 3.226376333s
--- PASS: TestInsertByTransaction2 (4.20s)
```
