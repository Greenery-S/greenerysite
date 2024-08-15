#!/bin/zsh

# go to the site folder
cd /Users/bytedance/Desktop/Projects/greenerysite/greenery-blog-site
hugo
git add .
git commit -m "update"
git push origin master

# get current time, commit with time
cd /Users/bytedance/Desktop/Projects/greenerysite/greenery-blog-site/public
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
git add .
git commit -m "publish at $current_time"
git push origin master

# open website
open https://greenery-s.github.io
