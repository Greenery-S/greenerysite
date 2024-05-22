---
title: "Classification"
date: 2024-05-18T21:10:35+08:00
draft: false
toc: false
tags:
  - hugo
  - site-building
  - rule
categories:
  - hugo
  - hugo-site-building
---

# Article Classification System

The classification of articles is managed by two fields: tags and categories. Tags are used for more casual classifications, such as golang and gopher, while categories are used for more formal topic classifications, such as go-dual-token-blog-system.

The URLs for the lists of tags and categories are /tags/ and /categories/, respectively. These URLs are set in the navigation bar, making it easy to view all tags and categories.

One thing to note is that the default sorting method for these lists is by time, so it is advisable to avoid having too many tags and categories, as this could lead to a cluttered list page.

## Tags

The values for tags can be filled in freely, such as golang and gopher. Any semantic tag can be used. Tags are set in the front matter of markdown files and can have multiple tags.

It is recommended to use singular forms for tags, such as rule instead of rules, to avoid duplicate tags.

```yaml
tags:
- golang
- gopher
- hugo
```  

## Categories

The values for categories are used for topic classifications, such as go-project-dual-token-blog-system. They are set in the front matter of markdown files.

Categories are hierarchical; for example, go is a primary category, go-project is a secondary category, and go-project-dual-token-blog-system is a tertiary category. Subcategories must include their parent categories. For an article under the go-project-dual-token-blog-system category, the categories field should be filled out as follows:

```yaml
categories:
- go
- go-project
- go-project-dual-token-blog-system
```

An article might fall under two main categories; for example, this article could be under both hugo and go main categories. Such dual categorization should be carefully considered and not done haphazardly.