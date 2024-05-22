---
title: "Orm Realized by Reflect"
date: 2024-05-19T21:50:59+08:00
draft: false
toc: false
images:
tags:
  - go
  - reflect
  - orm
categories:
    - go
    - go-basics
    - go-basics-database
---

# ORM核心技术—反射

> 教程,反射大全: https://zhuanlan.zhihu.com/p/411313885
> 
> code: https://github.com/Greenery-S/go-database/tree/master/orm

## 1 反射

**什么是反射**

- 在**运行期间**（不是编译期间）探知对象的类型信息和内存结构、更新变量、调用它们的方法

**何时使用反射**

- 函数的参数类型是interface{}，需要在运行时对原始类型进行判断，针对不同的类型采取不同的处理方式。比如json.Marshal(v interface{})

- 在运行时根据某些条件动态决定调用哪个函数，比如根据配置文件执行相应的算子函数
- 建议在初始化环节使用, 频繁调用的api不建议使用

## 2 使用例子

{{< image src="/images/orm-realized-by-reflect-example.png" alt="show-table" position="center" style="border-radius: 10px; width: 80%;" >}}

## 3 反射的弊端

1. 代码难以阅读，难以维护
1. 编译期间不能发现类型错误，覆盖测试难度很大，有些bug需要到线上运行很长时间才能发现，可能会造成严重用后果
1. 反射性能很差，通常比正常代码慢一到两个数量级。在对性能要求很高，或大量反复调用的代码块里建议不要使用反射

## 4 反射的基础数据类型

{{< image src="/images/orm-realized-by-reflect-data-type.png" alt="show-table" position="center" style="border-radius: 10px; width: 80%;" >}}

**reflact.Type** – 通过reflect.Type获取类型相关的信息

```go
type Type interface {
    MethodByName(string) (Method, bool) //根据名称获取方法
    Name() string   //获取结构体名称
    PkgPath() string //包路径
    Size() uintptr  //占用内存的大小
    Kind() Kind  //数据类型
    Implements(u Type) bool  //判断是否实现了某接口
    Field(i int) StructField  //第i个成员
    FieldByIndex(index []int) StructField  //根据index路径获取嵌套成员
    FieldByName(name string) (StructField, bool)  //根据名称获取成员
    Len() int  //容器的长度
    NumIn() int  //输出参数的个数
    NumOut() int  //返回参数的个数
}
```

**reflect.Value** – 通过reflect.Value获取、修改原始数据类型里的值

```go
type Value struct {
    // 代表的数据类型
    typ *rtype
    // 指向原始数据的指针
    ptr unsafe.Pointer
}
```

## 5 获取Field信息

```go
typeUser := reflect.TypeOf(User{})
for i := 0; i < typeUser.NumField() ; i++ {//成员变量的个数
	field := typeUser.Field(i)
	fmt.Printf("%s offset %d anonymous %t type %s exported %t json tag %s\n", 
	field.Name, //变量名称
	field.Offset, //相对于结构体首地址的内存偏移量，string类型会占据16个字节
	field.Anonymous, //是否为匿名成员
	field.Type, //数据类型，reflect.Type类型
	field.IsExported(), //包外是否可见（即是否以大写字母开头）
	field.Tag.Get("json")) //获取成员变量后面``里面定义的tag
}
```

## 6 ORM实现原理

```go
type User struct {
    Id         int    `gorm:"column:id;primaryKey"`
    Gender     string `gorm:"column:sex"`
    Name       string `gorm:"-"`
    FamilyName string
}
```

1. 带`gorm:"-"`的Field忽略掉
1. 通过field.Tag.Get("gorm") 获得gorm后面的内容
1. 把前缀" column:"去掉
1. 用;分隔，取第一部分
1. 没有显式写gorm Tag的Field将转为蛇形即对应mysql表里的column

```go
func GetGormFields(stc interface{}) []string {
        value := reflect.ValueOf(stc)
        typ := value.Type()
        columns := make([]string, 0, value.NumField())
        for i := 0; i < value.NumField(); i++ {
                fieldType := typ.Field(i)
                //不做ORM映射的字段跳过
                if fieldType.Tag.Get("gorm") == "-" {
                        continue
                }
                //如果没有gorm Tag，则把驼峰转为蛇形
                name := util.Camel2Snake(fieldType.Name)
                if len(fieldType.Tag.Get("gorm")) > 0 {
                        content := fieldType.Tag.Get("gorm")
                        if strings.HasPrefix(content, "column:") {
                                content = content[7:]
                                pos := strings.Index(content, ";")
                                if pos > 0 {
                                        name = content[0:pos]
                                } else if pos < 0 {
                                        name = content
                                }
                        }
                }
                columns = append(columns, name)
        }
        return columns
}
```
