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


## 4 Exit handlers

退出处理器是一个始终在工作流结束时执行的模板，无论成功还是失败。

退出处理器的一些常见用途包括：

- 在工作流运行后进行清理
- 发送工作流状态通知（例如，电子邮件/Slack）
- 将通过/失败状态发布到web-hook结果（例如，GitHub构建结果）
- 重新提交或提交另一个工作流

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: exit-handlers-
spec:
  entrypoint: intentional-fail
  onExit: exit-handler                  # invoke exit-handler template at end of the workflow
  templates:
  # primary workflow template
  - name: intentional-fail
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo intentional failure; exit 1"]

  # Exit handler templates
  # After the completion of the entrypoint template, the status of the
  # workflow is made available in the global variable {{workflow.status}}.
  # {{workflow.status}} will be one of: Succeeded, Failed, Error
  - name: exit-handler
    steps:
    - - name: notify
        template: send-email
      - name: celebrate
        template: celebrate
        when: "{{workflow.status}} == Succeeded"
      - name: cry
        template: cry
        when: "{{workflow.status}} != Succeeded"
  - name: send-email
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo send e-mail: {{workflow.name}} {{workflow.status}} {{workflow.duration}}"]
  - name: celebrate
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo hooray!"]
  - name: cry
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo boohoo!"]
```
    
{{<image src="/images/argo-workflow-exit-handlers.png" alt="argo-workflow-exit-handlers" position="center" style="border-radius: 8px;" size="60%">}}

## 5 Timeouts

您可以使用字段 `activeDeadlineSeconds` 来限制工作流的运行时间:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: timeouts-wf-
spec:
  activeDeadlineSeconds: 10 # 在10秒后终止工作流
  entrypoint: sleep
  templates:
  - name: sleep
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo sleeping for 1m; sleep 60; echo done"]
```

您也可以限制特定模板的运行时间:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: timeouts-tpl-
spec:
  entrypoint: sleep
  templates:
  - name: sleep
    activeDeadlineSeconds: 10 # 在10秒后终止容器模板
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo sleeping for 1m; sleep 60; echo done"]
```

## 6 Suspending

工作流可以通过以下方式挂起:

```sh
argo suspend WORKFLOW
```

或者在工作流中指定一个挂起步骤:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: suspend-template-
spec:
  entrypoint: suspend
  templates:
  - name: suspend
    steps:
    - - name: build
        template: argosay
        arguments:
          parameters:
            - name: message
              value: "I am suspended"
    - - name: approve
        template: approve
    - - name: delay
        template: delay
    - - name: release
        template: argosay
        arguments:
          parameters:
          - name: message
            value: "I am released"

  - name: approve
    suspend: {}

  - name: delay
    suspend:
      duration: "20"    # 必须是字符串。默认单位是秒。也可以是持续时间，例如："2m", "6h"

  - name: argosay
    inputs:
      parameters:
      - name: message
    container:
      image: yky8/argosay:v2
      command: [ "/usr/local/bin/argosay" ]
      args: [ "echo" ,"{{inputs.parameters.message}}" ]
```

一旦挂起,工作流将不会安排任何新的步骤,直到它被恢复.它可以通过以下方式手动恢复:

```sh
argo resume WORKFLOW
```

或者像上面的例子那样,通过设置一个持续时间限制来自动恢复.

{{<image src="/images/argo-workflow-suspending.png" alt="argo-workflow-suspending" position="center" style="border-radius: 8px;" size="60%">}}
```sh
> argo resume suspend-template-9plrz -n argo
INFO[2024-05-26T22:10:50.883Z] Workflow to be dehydrated                     Workflow Size=3079
workflow suspend-template-9plrz resumed
```
{{<image src="/images/argo-workflow-resume.png" alt="argo-workflow-resume" position="center" style="border-radius: 8px;" size="90%">}}
