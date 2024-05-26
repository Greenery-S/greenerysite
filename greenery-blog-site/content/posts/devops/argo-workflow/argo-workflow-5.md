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

When writing workflows, it is often useful to iterate over a set of inputs. This is how Argo Workflows handle looping.

There are three basic ways to run a template multiple times:

1. `withSequence` iterates over a sequence of numbers.
2. `withItems` accepts a list of items to process, which can be:
    - Plain single values, accessible via `{{item}}` in the template.
    - JSON objects, where each element can be referenced by its key as `{{item.key}}`.
3. `withParam` accepts a JSON array and iterates over it—these items can also be objects like in `withItems`. This is very powerful because you can generate JSON in another step of the workflow, creating a dynamic workflow.

### `withSequence` Example

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
           args: [ "echo", "hello world!" ]
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

### `withItems` Basic Example

This example uses `withItems` to loop over a list of items, replacing a string for each instantiated template.

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
        withItems:
        - hello world
        - goodbye world

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

### `withItems` JSON Object Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: loops-maps-
spec:
  entrypoint: loop-map-example
  templates:
  - name: loop-map-example
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
        - { image: 'debian', tag: '9.1' }
        - { image: 'debian', tag: '8.9' }
        - { image: 'alpine', tag: '3.6' }
        - { image: 'ubuntu', tag: '17.10' }

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

### `withParam` Example

To avoid hardcoding, you can use parameters to pass a JSON array and use `withParam` to iterate over it.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: loops-param-arg-
spec:
  entrypoint: loop-param-arg-example
  arguments:
    parameters:
    - name: os-list
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
        withParam: "{{inputs.parameters.os-list}}"

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

### `withParam` Data Passing Example

`withParam` can also be used to pass data between steps. In this example, we use the output of one step as the input for another.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generate

Name: loops-param-result-
spec:
  entrypoint: loop-param-result-example
  templates:
  - name: loop-param-result-example
    steps:
    - - name: generate
        template: gen-number-list
    - - name: sleep
        template: sleep-n-sec
        arguments:
          parameters:
          - name: seconds
            value: "{{item}}"
        withParam: "{{steps.generate.outputs.result}}"

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

### Accessing Aggregated Results of a Loop

Once the loop is complete, you can access the outputs of all iterations as a JSON array. The following example shows how to read it.

Note: The output of each iteration must be valid JSON.

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
            value: '{{steps.execute-parallel-steps.outputs.result}}'
  - name: print-json-entry
    inputs:
      parameters:
      - name: index
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

The last step of the above workflow should have the following output: inputs.parameters.aggregate-results: "[{"input":"1","transformed-input":"1.jpeg"},{"input":"2","transformed-input":"2.jpeg"},{"input":"3","transformed-input":"3.jpeg"}]"