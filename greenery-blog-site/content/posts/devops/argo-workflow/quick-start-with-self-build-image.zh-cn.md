---
title: "Quick Start With Self Build Image"
date: 2024-05-25T02:17:44+08:00
draft: true
toc: false
images:
tags:
  - argo-workflow
  - kubernetes
  - devops
  - k8s
  - docker
categories:
  - devops
  - devops-argo-workflow
---

# 比较坎坷的 "Quick" Start

最近想复习一下argo workflow，于是打算从官方文档开始，按照文档的步骤一步步来。然而，事情并没有那么顺利。官方的 docker/whalesay 镜像在新的docker版本下不支持了,这导致数百个以此为基础的hello world示例都无法正常运行。于是我决定自己构建一个镜像，来替代官方的docker/whalesay镜像。

## 1 创建本地k8s集群

用miniKube创建一个本地的k8s集群，方便测试。

```sh
brew install minikube
minikube start
```
## 2 下载argo workflow

```sh
kubectl create namespace argo
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v<<ARGO_WORKFLOWS_VERSION>>/quick-start-minimal.yaml
```

## 3 构建自己的镜像

### Copy whalesay 的逻辑到 argosay
这个大概用法就是 `argosay [command] [args]`, 然后根据command执行不同的逻辑。
- 如果command是空的，就输出"hello argo"
- 如果command是assert_contains，就在第二个参数中查找第三个参数
- 如果command是cat，就输出第二个参数的内容
- 如果command是echo，就输出第二个参数的内容
- 如果command是exit，就退出
- 如果command是sleep，就睡眠
- 如果command是sh，就执行第二个参数的shell命令
- 其他情况，就退出

```shell
# argosay

#!/bin/sh
set -eu

case ${1:-} in
  '')
    echo "hello argo"
    ;;
  assert_contains)
    grep -F "$3" "$2"
  ;;
  cat)
    cat "$2"
  ;;
  echo)
    case $# in
    1) echo "hello argo" ;;
    2) echo "$2" ;;
    3)
      mkdir -p "$(dirname $3)"
      echo "$2" > "$3"
      sleep 0.1 ;# sleep so the PNS executor has time to secure root file
      ;;
    default)
      exit 1
    esac
    ;;
  exit)
    exit "${2:-0}"
    ;;
  sleep)
    sleep "$2"
    ;;
  sh)
    sh "${2:-0}"
    ;;
  *)
    exit 1
esac
```
### 构建镜像

先写一个Dockerfile:

```DOCKERFILE
FROM alpine:latest

COPY argosay /usr/local/bin/argosay

RUN chmod +x /usr/local/bin/argosay

ENTRYPOINT ["/usr/local/bin/argosay"]
```

登录docker hub，创建一个新的repository，然后push镜像。

```sh
docker login

docker build -t argosay .
docker tag argosay:latest <<DOCKER_HUB_USERNAME>>/argosay:latest
docker push <<DOCKER_HUB_USERNAME>>/argosay:latest
```

### 写新的workflow manifest

```yaml
# argo-demo.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: argosay-example-
spec:
  entrypoint: argosay-example
  templates:
  - name: argosay-example
    container:
      image: <<DOCKER_HUB_USERNAME>>/argosay:latest  # 替换为您在远程仓库中的镜像路径
      command: ["/usr/local/bin/argosay"]
      args: ["echo", "hello world!"]
```

## 4 提交workflow

```sh
argo submit -n argo --watch argo-demo.yaml

# 查看workflow
argo list -n argo
argo get -n argo <<WORKFLOW_NAME>>
argo logs -n argo <<WORKFLOW_NAME>>
```

## 5 UI查看

```sh
kubectl port-forward svc/argo-server -n argo 2746:2746
open http://localhost:2746
```



