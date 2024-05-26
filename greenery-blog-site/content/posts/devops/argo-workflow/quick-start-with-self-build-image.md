---
title: "Quick Start With Self Build Image"
date: 2024-05-25T02:17:44+08:00
draft: false
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

# A Somewhat Rocky "Quick" Start

Recently, I wanted to review Argo Workflow, so I decided to start from the official documentation and follow the steps one by one. However, things didn't go as smoothly as expected. The official docker/whalesay image is no longer supported in the latest Docker version, which has caused hundreds of hello world examples based on it to fail to run properly. So, I decided to build my own image to replace the official docker/whalesay image.

## 1 Create a Local k8s Cluster

Create a local k8s cluster using miniKube for testing convenience.

```sh
brew install minikube
minikube start
minikube dashboard
```

## 2 Download Argo Workflow

```sh
kubectl create namespace argo
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v<<ARGO_WORKFLOWS_VERSION>>/quick-start-minimal.yaml
```

## 3 Build Your Own Image

### Copy Whalesay Logic to Argosay

This script has a rough usage of `argosay [command] [args]`, and then executes different logics based on the command.
- If the command is empty, it outputs "hello argo".
- If the command is assert_contains, it searches for the third parameter in the second parameter.
- If the command is cat, it outputs the content of the second parameter.
- If the command is echo, it outputs the content of the second parameter.
- If the command is exit, it exits.
- If the command is sleep, it sleeps.
- If the command is sh, it executes the shell command in the second parameter.
- Otherwise, it exits.

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

### Build the Image

First, write a Dockerfile:

```DOCKERFILE
FROM alpine:latest

COPY argosay /usr/local/bin/argosay

RUN chmod +x /usr/local/bin/argosay

ENTRYPOINT ["/usr/local/bin/argosay"]
```

Login to Docker Hub, create a new repository, and then push the image.

```sh
docker login

docker build -t argosay .
docker tag argosay:latest <<DOCKER_HUB_USERNAME>>/argosay:latest
docker push <<DOCKER_HUB_USERNAME>>/argosay:latest
```

### Write a New Workflow Manifest

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
      image: <<DOCKER_HUB_USERNAME>>/argosay:latest  # Replace with your image path in the remote repository
      command: ["/usr/local/bin/argosay"]
      args: ["echo", "hello world!"]
```

## 4 Submit the Workflow

```sh
argo submit -n argo --watch argo-demo.yaml

# View the workflow
argo list -n argo
argo get -n argo <<WORKFLOW_NAME>>
argo logs -n argo <<WORKFLOW_NAME>>
```

## 5 View in UI

```sh
kubectl port-forward svc/argo-server -n argo 2746:2746
open http://localhost:2746
```
