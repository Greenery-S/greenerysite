---
title: "Argo Workflow 5"
date: 2024-05-26T00:58:41+08:00
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

# Argo Workflow (5)

## 1 Loops

编写工作流时，能够迭代一组输入是非常有用的，因为这就是 Argo Workflows 执行循环的方式。

有三种基本方法可以多次运行一个模板。

1. `withSequence` 迭代一个数字序列。
2. `withItems` 接受一个待处理的项目列表，可以是
    - 纯的单个值，在模板中可以通过 `{{item}}` 使用
    - JSON 对象，其中每个元素可以通过它的键作为 `{{item.key}}` 来引用
3. `withParam` 接受一个 JSON 数组，并对其进行迭代——同样地，这些项目可以像 `withItems` 一样是对象。这非常强大，因为你可以在工作流的另一步生成 JSON，从而创建一个动态工作流。


### `withSequence` 示例

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
   generateName: loop-sequence-
spec:
   entrypoint: loop-sequence-example

   templates:
      - name: loop-sequence-example
        steps:
           - - name: hello-world-x5
               template: hello-world
               withSequence:
                  count: "5"

      - name: hello-world
        container:
           image: yky8/argosay:v2
           command: [ "/usr/local/bin/argosay" ]
           args: [ "echo","hello world!" ]
```
```shell
argo submit loop-withsequence.yaml -n argo
```
{{<image src="/images/argo-workflow-loop-with-sequence.png" alt="argo-workflow-loop-with-sequence" position="center" style="border-radius: 0px; width: 85%;" >}}

```text
Name:                loop-sequence-h5hzj
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Sun May 26 11:23:07 +0800 (10 seconds ago)
Started:             Sun May 26 11:23:07 +0800 (10 seconds ago)
Finished:            Sun May 26 11:23:17 +0800 (now)
Duration:            10 seconds
Progress:            5/5
ResourcesDuration:   11s*(100Mi memory),0s*(1 cpu)

STEP                        TEMPLATE               PODNAME                                     DURATION  MESSAGE
 ✔ loop-sequence-h5hzj      loop-sequence-example
 └─┬─✔ hello-world-x5(0:0)  hello-world            loop-sequence-h5hzj-hello-world-4274112881  4s
   ├─✔ hello-world-x5(1:1)  hello-world            loop-sequence-h5hzj-hello-world-276427469   4s
   ├─✔ hello-world-x5(2:2)  hello-world            loop-sequence-h5hzj-hello-world-634880841   4s
   ├─✔ hello-world-x5(3:3)  hello-world            loop-sequence-h5hzj-hello-world-2194008477  4s
   └─✔ hello-world-x5(4:4)  hello-world            loop-sequence-h5hzj-hello-world-2552461849  4s
```

### `withItems` 基础示例
这将使用 `withItems` 遍历一个项目列表,为每个实例化的模板替换一个字符串.
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: loops-
spec:
  entrypoint: loop-example
  templates:
  - name: loop-example
    steps:
    - - name: print-message
        template: argosay
        arguments:
          parameters:
          - name: message
            value: "{{item}}"
        withItems:              # invoke whalesay once for each item in parallel
        - hello world           # item 1
        - goodbye world         # item 2

  - name: argosay
    inputs:
      parameters:
      - name: message
    container:
      image: yky8/argosay:v2
      command: [ "/usr/local/bin/argosay" ]
      args: ["echo", "{{inputs.parameters.message}}"]
```
```shell
argo submit loop-withitems-basic.yaml -n argo
```
{{<image src="/images/argo-workflow-loop-with-items.png" alt="argo-workflow-loop-with-items" position="center" style="border-radius: 0px; width: 60%;" >}}

### `withItems` json对象示例

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: loops-maps-
spec:
  entrypoint: loop-map-example
  templates:
  - name: loop-map-example # parameter specifies the list to iterate over
    steps:
    - - name: test-linux
        template: cat-os-release
        arguments:
          parameters:
          - name: image
            value: "{{item.image}}"
          - name: tag
            value: "{{item.tag}}"
        withItems:
        - { image: 'debian', tag: '9.1' }       #item set 1
        - { image: 'debian', tag: '8.9' }       #item set 2
        - { image: 'alpine', tag: '3.6' }       #item set 3
        - { image: 'ubuntu', tag: '17.10' }     #item set 4

  - name: cat-os-release
    inputs:
      parameters:
      - name: image
      - name: tag
    container:
      image: "{{inputs.parameters.image}}:{{inputs.parameters.tag}}"
      command: [cat]
      args: [/etc/os-release]
```
```shell
argo submit loop-withitems-json.yaml -n argo
```
```text
Name:                loops-maps-dfkdd
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Sun May 26 14:01:38 +0800 (1 minute ago)
Started:             Sun May 26 14:01:38 +0800 (1 minute ago)
Finished:            Sun May 26 14:03:06 +0800 (now)
Duration:            1 minute 28 seconds
Progress:            4/4
ResourcesDuration:   0s*(1 cpu),2m13s*(100Mi memory)

STEP                                         TEMPLATE          PODNAME                                     DURATION  MESSAGE
 ✔ loops-maps-dfkdd                          loop-map-example
 └─┬─✔ test-linux(0:image:debian,tag:9.1)    cat-os-release    loops-maps-dfkdd-cat-os-release-1435759788  1m
   ├─✔ test-linux(1:image:debian,tag:8.9)    cat-os-release    loops-maps-dfkdd-cat-os-release-3975793734  1m
   ├─✔ test-linux(2:image:alpine,tag:3.6)    cat-os-release    loops-maps-dfkdd-cat-os-release-3565729669  12s
   └─✔ test-linux(3:image:ubuntu,tag:17.10)  cat-os-release    loops-maps-dfkdd-cat-os-release-1306728920  43s
```

### `withParam` 示例
为了避免硬编码,可以使用parameters来传递一个json数组.使用`withParam`迭代这个数组.
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: loops-param-arg-
spec:
  entrypoint: loop-param-arg-example
  arguments:
    parameters:
    - name: os-list                                     # a list of items
      value: |
        [
          { "image": "debian", "tag": "9.1" },
          { "image": "debian", "tag": "8.9" },
          { "image": "alpine", "tag": "3.6" },
          { "image": "ubuntu", "tag": "17.10" }
        ]

  templates:
  - name: loop-param-arg-example
    inputs:
      parameters:
      - name: os-list
    steps:
    - - name: test-linux
        template: cat-os-release
        arguments:
          parameters:
          - name: image
            value: "{{item.image}}"
          - name: tag
            value: "{{item.tag}}"
        withParam: "{{inputs.parameters.os-list}}"      # parameter specifies the list to iterate over

  # This template is the same as in the previous example
  - name: cat-os-release
    inputs:
      parameters:
      - name: image
      - name: tag
    container:
      image: "{{inputs.parameters.image}}:{{inputs.parameters.tag}}"
      command: [cat]
      args: [/etc/os-release]
```

### `withParam` step之间传递数据示例

`withParam` 也可以用来在步骤之间传递数据.这是最有用的.在这个例子中,我们将一个步骤的输出作为另一个步骤的输入.
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: loops-param-result-
spec:
  entrypoint: loop-param-result-example
  templates:
  - name: loop-param-result-example
    steps:
    - - name: generate
        template: gen-number-list
    # Iterate over the list of numbers generated by the generate step above
    - - name: sleep
        template: sleep-n-sec
        arguments:
          parameters:
          - name: seconds
            value: "{{item}}"
        withParam: "{{steps.generate.outputs.result}}"

  # Generate a list of numbers in JSON format
  - name: gen-number-list
    script:
      image: python:alpine3.6
      command: [python]
      source: |
        import json
        import sys
        json.dump([i for i in range(20, 31)], sys.stdout)

  - name: sleep-n-sec
    inputs:
      parameters:
      - name: seconds
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo sleeping for {{inputs.parameters.seconds}} seconds; sleep {{inputs.parameters.seconds}}; echo done"]
```
```shell
argo submit loop-withparam-advance.yaml -n argo
```
```text
STEP                         TEMPLATE                   PODNAME                                              DURATION  MESSAGE
 ✔ loops-param-result-tlqk6  loop-param-result-example
 ├───✔ generate              gen-number-list            loops-param-result-tlqk6-gen-number-list-2820570766  3s
 └─┬─✔ sleep(0:20)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-2838083538      29s
   ├─✔ sleep(1:21)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-1673755972      27s
   ├─✔ sleep(2:22)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-1057415402      1m
   ├─✔ sleep(3:23)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-3164894936      39s
   ├─✔ sleep(4:24)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-478396042       57s
   ├─✔ sleep(5:25)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-1092769612      1m
   ├─✔ sleep(6:26)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-3524356130      48s
   ├─✔ sleep(7:27)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-803927512       41s
   ├─✔ sleep(8:28)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-1975034882      57s
   ├─✔ sleep(9:29)           sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-1202660980      49s
   └─✔ sleep(10:30)          sleep-n-sec                loops-param-result-tlqk6-sleep-n-sec-291803978       56s
```

### 访问循环的聚合结果

一旦循环完成,可以将所有迭代的输出作为JSON数组进行访问,下面的示例展示了如何读取它.

请注意:每次迭代的输出必须是有效的JSON.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: loop-test
spec:
  entrypoint: main
  templates:
  - name: main
    steps:
    - - name: execute-parallel-steps
        template: print-json-entry
        arguments:
          parameters:
          - name: index
            value: '{{item}}'
        withParam: '[1, 2, 3]'
    - - name: call-access-aggregate-output
        template: access-aggregate-output
        arguments:
          parameters:
          - name: aggregate-results
            # If the value of each loop iteration isn't a valid JSON,
            # you get a JSON parse error:
            value: '{{steps.execute-parallel-steps.outputs.result}}'
  - name: print-json-entry
    inputs:
      parameters:
      - name: index
    # The output must be a valid JSON
    script:
      image: alpine:latest
      command: [sh]
      source: |
        cat <<EOF
        {
        "input": "{{inputs.parameters.index}}",
        "transformed-input": "{{inputs.parameters.index}}.jpeg"
        }
        EOF
  - name: access-aggregate-output
    inputs:
      parameters:
      - name: aggregate-results
        value: 'no-value'
    script:
      image: alpine:latest
      command: [sh]
      source: |
        echo 'inputs.parameters.aggregate-results: "{{inputs.parameters.aggregate-results}}"'
```
```shell
argo submit loop-withparam-aggr-result.yaml -n argo
```
{{<image src="/images/argo-workflow-loop-withparam-aggr-result.png" alt="argo-workflow-loop-withparam-aggr-result" position="center" style="border-radius: 0px; width: 60%;" >}}

上述工作流的最后一步应该有以下输出: inputs.parameters.aggregate-results: "[{"input":"1","transformed-input":"1.jpeg"},{"input":"2","transformed-input":"2.jpeg"},{"input":"3","transformed-input":"3.jpeg"}]"