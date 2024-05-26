---
title: "Argo Workflow 6"
date: 2024-05-26T14:36:26+08:00
draft: false
toc: false
images:
tags:
  - argo-workflow
  - loop
  - conditionals
categories:
  - devops
  - devops-argo-workflow
---

# Argo Workflow (6)

## 1 Conditionals

支持条件执行.语法是由 govaluate 实现的,它提供了对复杂语法的支持.请参见以下示例:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: coinflip-
spec:
  entrypoint: coinflip
  templates:
  - name: coinflip
    steps:
    # flip a coin
    - - name: flip-coin
        template: flip-coin
    # evaluate the result in parallel
    - - name: heads
        template: heads                       # call heads template if "heads"
        when: "{{steps.flip-coin.outputs.result}} == heads"
      - name: tails
        template: tails                       # call tails template if "tails"
        when: "{{steps.flip-coin.outputs.result}} == tails"
    - - name: flip-again
        template: flip-coin
    - - name: complex-condition
        template: heads-tails-or-twice-tails
        # call heads template if first flip was "heads" and second was "tails" OR both were "tails"
        when: >-
            ( {{steps.flip-coin.outputs.result}} == heads &&
              {{steps.flip-again.outputs.result}} == tails
            ) ||
            ( {{steps.flip-coin.outputs.result}} == tails &&
              {{steps.flip-again.outputs.result}} == tails )
      - name: heads-regex
        template: heads                       # call heads template if ~ "hea"
        when: "{{steps.flip-again.outputs.result}} =~ hea"
      - name: tails-regex
        template: tails                       # call heads template if ~ "tai"
        when: "{{steps.flip-again.outputs.result}} =~ tai"

  # Return heads or tails based on a random number
  - name: flip-coin
    script:
      image: python:alpine3.6
      command: [python]
      source: |
        import random
        result = "heads" if random.randint(0,1) == 0 else "tails"
        print(result)

  - name: heads
    container:
      image: alpine:3.6
      command: [sh, -c]
      args: ["echo \"it was heads\""]

  - name: tails
    container:
      image: alpine:3.6
      command: [sh, -c]
      args: ["echo \"it was tails\""]

  - name: heads-tails-or-twice-tails
    container:
      image: alpine:3.6
      command: [sh, -c]
      args: ["echo \"it was heads the first flip and tails the second. Or it was two times tails.\""]
```

{{<image src="/images/argo-workflow-conditionals.png" alt="argo-workflow-conditionals" position="center" style="border-radius: 8px;" size="100%">}}

## 2 Recursion

模板之间的递归调用是允许的.请参见以下示例.这个示例会使得翻硬币直到正面朝上,才会结束.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: coinflip-recursive-
spec:
  entrypoint: coinflip
  templates:
  - name: coinflip
    steps:
    # flip a coin
    - - name: flip-coin
        template: flip-coin
    # evaluate the result in parallel
    - - name: heads
        template: heads                 # call heads template if "heads"
        when: "{{steps.flip-coin.outputs.result}} == heads"
      - name: tails                     # keep flipping coins if "tails"
        template: coinflip
        when: "{{steps.flip-coin.outputs.result}} == tails"

  - name: flip-coin
    script:
      image: python:alpine3.6
      command: [python]
      source: |
        import random
        result = "heads" if random.randint(0,1) == 0 else "tails"
        print(result)

  - name: heads
    container:
      image: alpine:3.6
      command: [sh, -c]
      args: ["echo \"it was heads\""]
```
    
{{<image src="/images/argo-workflow-recursion.png" alt="argo-workflow-recursion" position="center" style="border-radius: 8px;" size="100%">}}

## 3 Retry失败或错误的步骤

可以指定一个重试策略,该策略将决定如何重试失败或错误的步骤:

```yaml
# 此示例演示了如何使用重试退避
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: retry-backoff-
spec:
  entrypoint: retry-backoff
  templates:
  - name: retry-backoff
    retryStrategy:
      limit: 10
      retryPolicy: "Always"
      backoff:
        duration: "1"      # 必须是字符串。默认单位是秒。也可以是持续时间，例如："2m", "6h", "1d"
        factor: 2
        maxDuration: "1m"  # 必须是字符串。默认单位是秒。也可以是持续时间，例如："2m", "6h", "1d"
      affinity:
        nodeAntiAffinity: {}
    container:
      image: python:alpine3.6
      command: ["python", -c]
      # 有66%的概率失败
      args: ["import random; import sys; exit_code = random.choice([0, 1, 1]); sys.exit(exit_code)"]
```

- `limit` 是容器将被重试的最大次数.
- `retryPolicy` 指定容器在失败,错误,两者都有或仅在瞬态错误(例如 i/o 或 TLS 握手超时)时是否会被重试."Always" 在错误和失败时都会重试.也可用:OnFailure(默认),"OnError",和 "OnTransientError"(在 v3.0.0-rc2 之后可用).
- `backoff` 是一个指数退避
- `nodeAntiAffinity` 防止在同一主机上运行步骤.当前实现只允许空的 nodeAntiAffinity(即 nodeAntiAffinity: {}),并且默认使用标签 kubernetes.io/hostname 作为选择器.

提供一个空的重试策略(即 retryStrategy::{})将导致容器重试直到完成.