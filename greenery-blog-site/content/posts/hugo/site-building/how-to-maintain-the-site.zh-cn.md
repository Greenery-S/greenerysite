---
title: "How to Maintain the Site"
date: 2024-05-19T02:32:21+08:00
draft: false
toc: false
images:
tags:
  - hugo
  - site-building
  - operation
  - maintain
  - github
categories:
  - hugo
  - hugo-site-building
---

# 如何通过hugo和github维护博客

[gitpage](https://pages.github.com/)是一个非常好的博客托管平台,它可以让你通过git的方式来维护你的博客.这样的方式非常适合程序员,因为我们大多数都会使用git.

[hugo](https://gohugo.io/)是一个非常好的静态网站生成器,它可以让你通过markdown文件来生成静态网站.这样的方式非常适合程序员,因为我们大多数都会使用markdown.

这篇文章会教你如何通过hugo和github来维护你的博客.

## 安装hugo和git

首先你需要安装hugo和git.你可以通过以下方式安装:

```bash
# 安装hugo
brew install hugo
# 安装git
brew install git
```

## 在github上创建2个仓库

你需要在github上创建2个仓库,一个用来存放hugo的源文件,一个用来存放hugo生成的静态网站.

存放hugo生成的静态网站的仓库名字是`<yourname.github.io>`,这个仓库是一个公开仓库,用来存放你的hugo源文件.

## 本地初始化网站项目

```bash
# 初始化hugo项目
hugo new site <site-name>
# 初始化git项目
git init
# 添加远程仓库
git remote add origin <your-site-source-repo>
```

## 创建文章,预览,修改

```bash
# 创建文章
hugo new posts/my-first-post.md
# 预览
hugo server -D
```

## 修改主题

```bash
# 下载主题
git submodule add <theme-url> themes/<theme-name>
# 修改配置文件
cp themes/<theme-name>/exampleSite/config.toml 
```

配置的修改因主题而异,请参考主题的文档.比如我使用的'hello-friend-ng'主题,使用建议:

- 所有的文章都应该放在`content/posts`目录下
- 可以配置`config.toml`文件来修改menu:
    ```toml
  [[menu.main]]
    identifier = "about"
    name = "About"
    url = "posts/about"
    weight = 1
  [[menu.main]]
    identifier = "site-building"
    name = "Site-building"
    url = "categories/hugo-site-building/"
    weight = 5
    ```

## 发布网站到github.io

```bash
# 生成静态网站
hugo
# 提交到github
cd public
git add .
git commit -m "add new post"
git push origin master
```
访问`https://<yourname>.github.io`就可以看到你的博客了.

> 参考链接:
> - [教程](https://cuttontail.blog/blog/create-a-wesite-using-github-pages-and-hugo/)