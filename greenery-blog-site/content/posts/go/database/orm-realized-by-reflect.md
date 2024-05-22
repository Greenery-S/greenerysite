---
title: "ORM Realized by Reflect"
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
# Core Technology of ORM—Reflection

> Tutorial, Reflection Guide: [https://zhuanlan.zhihu.com/p/411313885](https://zhuanlan.zhihu.com/p/411313885)
> 
> code: https://github.com/Greenery-S/go-database/tree/master/orm

## 1 Reflection

**What is Reflection**

- Reflection is the ability to inspect and modify an object’s type information and memory structure, update variables, and call methods during **runtime** (not compile time).

**When to Use Reflection**

- When a function’s parameter type is `interface{}`, and you need to determine the original type at runtime to handle different types accordingly. For example, `json.Marshal(v interface{})`.
- When you need to dynamically decide which function to call at runtime based on certain conditions, such as executing the appropriate operator function based on a configuration file.
- It is recommended to use reflection during the initialization phase. Avoid using it frequently in API calls due to performance concerns.

## 2 Usage Examples

{{< image src="/images/orm-realized-by-reflect-example.png" alt="show-table" position="center" style="border-radius: 10px; width: 80%;" >}}

## 3 Drawbacks of Reflection

1. Code readability and maintainability are poor.
2. Type errors cannot be detected during compilation, making comprehensive testing challenging. Some bugs may only be discovered after prolonged runtime in production, potentially causing severe consequences.
3. Reflection performance is poor, typically one to two orders of magnitude slower than regular code. Avoid using reflection in performance-critical or frequently called code blocks.

## 4 Basic Data Types of Reflection

{{< image src="/images/orm-realized-by-reflect-data-type.png" alt="show-table" position="center" style="border-radius: 10px; width: 80%;" >}}

**reflect.Type** – Retrieve type-related information using `reflect.Type`

```go
type Type interface {
    MethodByName(string) (Method, bool) // Retrieve method by name
    Name() string   // Get the struct name
    PkgPath() string // Package path
    Size() uintptr  // Memory size
    Kind() Kind  // Data type
    Implements(u Type) bool  // Check if it implements an interface
    Field(i int) StructField  // Retrieve the i-th field
    FieldByIndex(index []int) StructField  // Retrieve nested field by index path
    FieldByName(name string) (StructField, bool)  // Retrieve field by name
    Len() int  // Container length
    NumIn() int  // Number of input parameters
    NumOut() int  // Number of return parameters
}
```

**reflect.Value** – Retrieve and modify values within the original data type using `reflect.Value`

```go
type Value struct {
    // The type represented by this value
    typ *rtype
    // Pointer to the original data
    ptr unsafe.Pointer
}
```

## 5 Retrieving Field Information

```go
typeUser := reflect.TypeOf(User{})
for i := 0; i < typeUser.NumField(); i++ { // Number of fields
    field := typeUser.Field(i)
    fmt.Printf("%s offset %d anonymous %t type %s exported %t json tag %s\n", 
    field.Name, // Field name
    field.Offset, // Memory offset from the struct's start address; string type occupies 16 bytes
    field.Anonymous, // Is it an anonymous field
    field.Type, // Data type, of type reflect.Type
    field.IsExported(), // Is it visible outside the package (i.e., starts with an uppercase letter)
    field.Tag.Get("json")) // Retrieve the tag defined after the field in ``
}
```

## 6 Principles of ORM Implementation

```go
type User struct {
    Id         int    `gorm:"column:id;primaryKey"`
    Gender     string `gorm:"column:sex"`
    Name       string `gorm:"-"`
    FamilyName string
}
```

1. Ignore fields marked with `gorm:"-"`
2. Retrieve the content after `gorm` from `field.Tag.Get("gorm")`
3. Remove the prefix `"column:"`
4. Split the string by `;` and take the first part
5. Fields without an explicit `gorm` tag will be converted to snake case, corresponding to the MySQL table column

```go
func GetGormFields(stc interface{}) []string {
    value := reflect.ValueOf(stc)
    typ := value.Type()
    columns := make([]string, 0, value.NumField())
    for i := 0; i < value.NumField(); i++ {
        fieldType := typ.Field(i)
        // Skip fields not mapped to ORM
        if fieldType.Tag.Get("gorm") == "-" {
            continue
        }
        // Convert camel case to snake case if there is no gorm tag
        name := util.Camel2Snake(fieldType.Name)
        if len(fieldType.Tag.Get("gorm")) > 0 {
            content := fieldType.Tag.Get("gorm")
            if strings.HasPrefix(content, "column:") {
                content = content[7:]
                pos := strings.Index(content, ";")
                if pos > 0 {
                    name = content[:pos]
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