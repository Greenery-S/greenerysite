---
title: "Classification"
date: 2024-05-18T20:56:05+08:00
draft: false
toc: false
images:
tags:
  - hugo
  - site-building
  - rule
categories:
  - hugo
  - hugo-site-building
---

# 文章的分类系统

文章的分类由`tags`和`categories`两个字段管理.`tag`用来做更加随意的分类,比如`golang`和`gopher`,`categories`用来做更加严格的
**专题**分类,比如`go-dual-token-blog-system`.

`tags`和`categories`的列表页面的url分别是`/tags/`和`/categories/`.这两个url被设置到了导航栏中,点击后可以查看所有的`tags`
和`categories`,非常方便.

唯一需要注意的是这个列表的排序方式默认是按时间的,所以尽量避免过多的`tags`和`categories`,否则会导致列表页面的混乱.

## tags

tag值可以随意填写,比如`golang`和`gopher`.任何语义的tag都可以填写.它被设置在markdown文件的front matter中,并且可以有多个tag.

建议填写单数形式的tag,比如`rule`而不是`rules`.这样可以避免tag的重复.

```yaml
tags:
  - golang
  - gopher
  - hugo
```

## categories

categories值是专题分类,比如`go-project-dual-token-blog-system`.它被设置在markdown文件的front matter中.

这个分类是分级的,比如`go`是一级分类,`go-project`是二级分类,`go-project-dual-token-blog-system`
是三级分类.子分类必须填写父分类,比如,对于在`go-project-dual-token-blog-system`分类下的文章,`categories`字段应该填写如下.

```yaml
categories:
  - go
  - go-project
  - go-project-dual-token-blog-system
```

一篇文章可能是处于两个大分类下的,比如本文就可以同时处于`hugo`和`go`两个大分类下. 这种一定要谨慎考虑,不要乱填写.