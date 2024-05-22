---
title: "MySQL Optimization"
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
# MySQL Performance Tuning
> code: https://github.com/Greenery-S/go-database/tree/master/mysql

### 1 Practical Recommendations

- Always use lowercase when writing SQL.
- Check if a table already exists before creating it using `if not exists`.
- Add `comment` to all columns and tables.
- Use `char` for short strings to benefit from fixed length and memory alignment, which improves read/write performance. `varchar` fields may cause memory fragmentation with frequent modifications.

- Use shorter data types whenever possible, e.g., `tinyint` vs `int`, `float` vs `double`, `date` vs `datetime`.

```sql
CREATE TABLE if not exists `student` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key auto-increment id',
  `name` char(10) NOT NULL COMMENT 'Name',
  `province` char(6) NOT NULL COMMENT 'Province',
  `city` char(10) NOT NULL COMMENT 'City',
  `addr` varchar(100) DEFAULT '' COMMENT 'Address',
  `score` float NOT NULL DEFAULT '0' COMMENT 'Exam score',
  `enrollment` date NOT NULL COMMENT 'Enrollment date',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_location` (`province`,`city`)
) ENGINE=InnoDB AUTO_INCREMENT=100020 DEFAULT CHARSET=utf8 COMMENT='Student basic information';
```

## 2 null

- `default null` differs from `default ''` and `default 0`.

- `is null`, `is not null` differ from `!= ''`, `!= 0`.

- Set fields to `not null` whenever possible:

    - Some DB indexes do not allow null values.
    - Statistics on columns with null values may be inaccurate.
    - Null values can sometimes severely degrade system performance.

## 3 Avoiding Slow Queries (e.g., >1s)

- Most slow queries result from improper index usage.
- Avoid creating too many indexes, as it slows down writes.
- Use the default InnoDB engine in most cases, rather than MyISAM.
- Avoid `select *`, only select the columns you need.
- Use `in` instead of `or` when possible, as `in` is more efficient.
- Limit the number of elements in `in` to 300-500.
- Avoid model queries like `like`, as they cannot use indexes effectively.
- Use `limit 1` if you are sure the result is a single row, to avoid full table scans.
- `limit m,n` retrieves the first m+n rows but only returns the last n rows. Use `id>x` to replace this pagination method.
- Batch operations in a single SQL statement or as a single transaction to reduce contention on shared resources.
- Avoid large transactions; use small transactions to reduce lock waiting and contention.
- Limit the number of rows queried or updated at once to around 1000.
- Avoid join operations; handle join logic in application code.
- Do not use MySQL built-in functions as they do not utilize query caching; handle complex logic in your code.

## 4 B+ Tree

1. B stands for Balance. In an m-ary tree, each node has up to m data items and at least m/2 data items (except the root node).
2. Leaf nodes store all data and are linked for sequential access.
3. Each node is designed as a multiple of memory pages (4K). In MySQL, m=1200, so the first two levels of the tree are stored in memory.

{{< image src="/images/mysql-optimization-bplustree.png" alt="b+tree" position="center" style="border-radius: 20px; width: 300px;" >}}

## 5 Indexes

- MySQL indexes use B+ trees by default.
    - Why not hashtable? 1) Not all data can be loaded into memory; 2) Not suitable for range queries.
- The primary key automatically gets indexed. The B+ tree built by the primary key contains data for all columns, whereas a normal index’s B+ tree stores only the primary key, requiring another lookup (back to the table).
- The prefix of a composite index also functions as an index.
- Use `explain` before SQL statements to check index usage.
- If MySQL does not choose the optimal index plan, use `force index (index_name)` before `where`.

```sql
show create table student;
```

{{< image src="/images/mysql-optimization-show-table.png" alt="show-table" position="center" style="border-radius: 10px; width: 100%;" >}}

## 6 Covering Indexes

{{< image src="/images/mysql-optimization-cover-index.png" alt="cover-index" position="center" style="border-radius: 10px; width: 300;" >}}

```sql
explain select city from student where name='张三' and province='北京';
explain select city from student force index (idx_location) where name='张三' and province='北京';
```

{{< image src="/images/mysql-optimization-explain-select.png" alt="cover-index" position="center" style="border-radius: 10px; width: 300;" >}}

- The first query needs to go back to the table.
- The second SQL query only needs to query the `city`, and it hits the composite index (`province`, `city`), so it does not need to go back to the table. This is a covering index (hits a non-primary key index without needing to go back to the table).
- The covering index will show "Using index" in the Extra field of the `explain` output.

## 7 SQL Injection Attacks

**CASE 1**

- `sql = "select username, password from user where username='" + username + "' and password='" + password + "'";`
- Variables `username` and `password` come from the frontend input. If a user inputs `username` as lily and `password` as `aaa' or '1'='1`, the complete SQL would be `select username, password from user where username='lily' and password='aaa' or '1'='1'`.
- This returns all records in the table. If the record count is greater than 0, login is allowed, so lily’s account is compromised.

**CASE 2**

- `sql="insert into student (name) values ('" + username + " ') ";`
- The variable `username` comes from the frontend input. If the user inputs `username` as `lily'); drop table student;--`, the complete SQL would be `insert into student (name) values ('lily'); drop table student;--')`.
- The comment `--` ignores the trailing `')`, deleting the entire table.

### Prevention Methods

**Overall**

- Validate frontend inputs with regex and length checks.
- Escape or encode special characters (e.g., <>&*; '" etc.). Go’s `text/template` package function `HTMLEscapeString` can escape strings.
- Avoid embedding user inputs directly in SQL statements; use **parameterized queries** like `Prepare`, `Query`, `Exec(query string, args ...interface{})`.
- Use professional SQL injection detection tools such as sqlmap and SQLninja.
- **Avoid displaying SQL error messages** to prevent attackers from exploiting them.
- No single method can prevent all SQL injection attacks; use a combination of methods.

**Stmt**

- Define an SQL template: `stmt, err := db.Prepare("update student set score=score+? where city=?")`.

- Use the template multiple times:

  ```go
  res, err := stmt.Exec(10, "Shanghai");
  res, err = stmt.Exec(9, "Shenzhen");
  ```

- Avoid SQL concatenation (vulnerable to SQL injection and cannot leverage compilation optimization): `db.Where(fmt.Sprintf("merchant_id = %s", merchantId))`.

```sql
CREATE TABLE if not exists `login` (
  `username` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

```go
// Returns true if login is successful. Vulnerable to SQL injection.
func LoginUnsafe(db *gorm.DB, name, passwd string) bool {
  var cnt int64;
  db.Table("login").Select("*").Where("username='" + name + "' and password='" + passwd + "'").Count(&cnt);
  return cnt > 0;
}

// Returns true if login is successful. Protected against SQL injection.
func LoginSafe(db *gorm.DB, name, passwd string) bool {
  var cnt int64;
  db.Table("login").Select("*").Where("username=? and password=?", name, passwd).Count(&cnt);
  return cnt > 0;
}
```

```go
func TestLoginUnsafe(t *testing.T) {
  db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{PrepareStmt: true}); // Enforce PrepareStmt
  if err != nil {
    panic(err);
  }
  if LoginUnsafe(db, "tom", "123456") == false {
    t.Fail();
  }
  if LoginUnsafe(db, "tom", "456789") == true {
    t.Fail();
  }
  // select * from login

 where username='tom' and password='456789' or '1'='1'
  if LoginUnsafe(db, "tom", "456789' or '1'='1") == false {
    t.Fail();
  }
}

func TestLoginSafe(t *testing.T) {
  db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{PrepareStmt: true}); // Enforce PrepareStmt
  if err != nil {
    panic(err);
  }
  if LoginSafe(db, "tom", "123456") == false {
    t.Fail();
  }
  if LoginSafe(db, "tom", "456789") == true {
    t.Fail();
  }
  if LoginSafe(db, "tom", "456789' or '1'='1") == true {
    t.Fail();
  }
}
```

**SQL Precompilation**

- DB execution of SQL involves three steps:
    1. Lexical and semantic analysis.
    2. SQL statement optimization and execution plan formulation.
    3. Execution and return of results.

- SQL precompilation replaces user inputs with placeholders (`?`), precompiles the template SQL, and injects user inputs at runtime.

- This prevents SQL injection and allows caching of precompiled SQL statements, avoiding repeated analysis and optimization.

```go
func BenchmarkQueryWithoutPrepare(b *testing.B) {
  client, err := gorm.Open(mysql.Open(dsn), &gorm.Config{}); // PrepareStmt not specified
  if err != nil {
    panic(err);
  }
  b.ResetTimer();

  for i := 0; i < b.N; i++ {
    LoginUnsafe(client, name, passwd);
  }
}

func BenchmarkQueryWithPrepare(b *testing.B) {
  client, err := gorm.Open(mysql.Open(dsn), &gorm.Config{PrepareStmt: true}); // Enforce PrepareStmt
  if err != nil {
    panic(err);
  }
  b.ResetTimer();

  for i := 0; i < b.N; i++ {
    LoginUnsafe(client, name, passwd);
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

## 8 Pagination Queries

- `limit m,n` retrieves the first m+n rows but only returns the last n rows. Use `id>x` to replace this pagination method.
- Full table scan:
    1. Directly selecting `* from table` is slow, violating the principle of not querying too many rows at once.
    2. Pagination appears to query few rows, but it executes multiple full table scans.
    3. Fix `page_size` and maintain the maximum queried `id (max_id)`. Query using `where id>maxid limit page_size`, exiting the loop when the result is empty.

{{< image src="/images/mysql-optimization-pagenate.png" alt="pagination" position="center" style="border-radius: 10px; width: 300;" >}}

## 9 Transactions

- Batch operations should be done in a single SQL statement; otherwise, bundle them in a transaction and commit once to reduce contention on shared resources.

```go
const (
  INSERT_COUNT = 100000;
)

// Insert one by one
func InsertOneByOne(db *gorm.DB) {
  begin := time.Now();
  for i := 0; i < INSERT_COUNT; i++ {
    student := Student{Name: "Student" + strconv.Itoa(i), Province: "Beijing", City: "Beijing", Score: 38, Enrollment: time.Now()};
    if err := db.Create(&student).Error; err != nil { // Note: pass the pointer of student
      fmt.Println(err);
      return;
    }
  }
  fmt.Println("total", time.Since(begin));
}

// Insert within a transaction
func InsertByTransaction1(db *gorm.DB) {
  begin := time.Now();
  tx := db.Begin();
  for i := 0; i < INSERT_COUNT; i++ {
    student := Student{Name: "Student" + strconv.Itoa(i), Province: "Beijing", City: "Beijing", Score: 38, Enrollment: time.Now()};
    if err := tx.Create(&student).Error; err != nil {
      fmt.Println(err);
      return;
    }
  }
  tx.Commit();
  fmt.Println("total", time.Since(begin));
}

// Insert multiple rows at once within a transaction
func InsertByTransaction2(db *gorm.DB) {
  begin := time.Now();
  tx := db.Begin();
  const BATCH = 100; // Insert multiple rows in a single SQL statement
  for i := 0; i < INSERT_COUNT; i += BATCH {
    students := make([]Student, 0, BATCH);
    for j := 0; j < BATCH; j++ {
      student := Student{Name: "Student" + strconv.Itoa(i+j), Province: "Beijing", City: "Beijing", Score: 38, Enrollment: time.Now()};
      students = append(students, student);
    }
    if err := tx.Create(&students).Error; err != nil {
      fmt.Println(err);
      return;
    }
  }
  tx.Commit();
  fmt.Println("total", time.Since(begin));
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

