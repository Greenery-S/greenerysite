---
title: "Why Open This Series"
date: 2024-06-07T17:37:02+08:00
draft: false
toc: false
images:
tags:
  - go
  - design-pattern
categories:
  - go
  - go-design-pattern
---

# 为什么开启设计模式系列

我发现我写的代码越来越难维护,越来越难扩展.我需要学习一些设计模式,来提高代码的质量.

有用的参考资料:
- https://refactoringguru.cn/design-patterns/catalog : 
  - 图文并茂,很容易理解. 23种全,但是不深入.因为有付费版.
- https://github.com/mohuishou/go-design-pattern :
  - 是极客时间[设计模式之美](https://time.geekbang.org/column/intro/100039001?utm_campaign=geektime_search&utm_content=geektime_search&utm_medium=geektime_search&utm_source=geektime_search&utm_term=geektime_search&tab=intro)的笔记, 我觉得不需要买这个,因为他是java的
  - 这个有博客讲解的,比较推荐.
- https://github.com/senghoo/golang-design-pattern :
  - 这是<研磨设计模式>的go实现, 比较推荐. 来源:https://www.javaweb.shop/
  

## 和k8s源码学习相结合

这个更新在我一刷完设计模式. 我本来就打算在刷完设计模式后就开始看k8s的源码,这是两个独立不相干的事情.

但是,我刚开始看client-go的源码,就发现了很多设计模式里看到的东西! 我发现k8s这个项目作为golang开源项目的标杆,大量使用到设计模式这是很自然的事.

因此,我现在依旧会继续看k8s,但是也会把其中的设计模式的部分归纳出来,继续放在这个主题下.


