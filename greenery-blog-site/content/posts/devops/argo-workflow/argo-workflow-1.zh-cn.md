---
title: "Argo Workflow 1"
date: 2024-05-25T03:46:15+08:00
draft: false
toc: false
images:
tags:
  - argo-workflow
categories:
  - devops
  - devops-argo-workflow
---

# Argo Workflow (1)

大量例子在此: https://github.com/argoproj/argo-workflows/tree/main/examples
但是,由于`docker/whalesay`镜像不再支持,导致很多例子无法运行,需要自己构建一个镜像来替代它.

## 1 Argo CLI

```sh
argo submit hello-world.yaml    # submit a workflow spec to Kubernetes
argo list                       # list current workflows
argo get hello-world-xxx        # get info about a specific workflow
argo logs hello-world-xxx       # print the logs from a workflow
argo delete hello-world-xxx     # delete workflow
```

用`kubectl`也可以, 都要指定`namespace`

## 2 Hello World

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow                  # new type of k8s spec
metadata:
  generateName: hello-world-    # name of the workflow spec
spec:
  entrypoint: argosay          # invoke the whalesay template
  templates:
    - name: argosay              # name of the template
      container:
        image: yky8/argosay:v2
        command: ["/usr/local/bin/argosay"]
        args: ["echo", "hello world!"]
        resources: # limit the resources
          limits:
            memory: 32Mi
            cpu: 100m
```
执行 `argo submit -n argo --watch hello-world.yaml`:
```text
Name:                hello-world-852mj
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Sat May 25 02:58:27 +0800 (10 seconds ago)
Started:             Sat May 25 02:58:27 +0800 (10 seconds ago)
Finished:            Sat May 25 02:58:37 +0800 (now)
Duration:            10 seconds
Progress:            1/1
ResourcesDuration:   0s*(1 cpu),1s*(100Mi memory)

STEP                  TEMPLATE  PODNAME            DURATION  MESSAGE
 ✔ hello-world-852mj  argosay   hello-world-852mj  3s
```

## 3 Parameters

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-parameters-
spec:
  # invoke the whalesay template with
  # "hello world" as the argument
  # to the message parameter
  entrypoint: argosay
  arguments:
    parameters:
      - name: message
        value: hello world

  templates:
    - name: argosay
      inputs:
        parameters:
          - name: message       # parameter declaration
      container:
        # run cowsay with that message input parameter as args
        image: yky8/argosay:v2
        command: [ "/usr/local/bin/argosay" ]
        args: [ "echo" ,"{{inputs.parameters.message}}" ]
```
**第一种: parameter 来自 `-p` 参数**
```shell
argo submit arguments-parameters.yaml -n argo -p message="goodbye world"
```
**第二种: parameter 来自 文件**
```yaml
# params.yaml
message: goodbye world
```
```shell
argo submit arguments-parameters.yaml -n argo --parameter-file params.yaml
```
**改写任意spec中的参数**
命令行参数也可以用于覆盖默认入口点，并调用工作流规范中的任何模板。例如，如果您添加了一个名为 argosay-caps 的新版本的 argosay 模板，但您不想更改默认的入口点，您可以通过以下命令行调用它：

```shell
argo submit arguments-parameters.yaml -n argo --entrypoint argosay-caps
```

通过结合 `--entrypoint` 和 `-p` 参数的使用，您可以调用工作流规范中的任何模板，并传递任何您喜欢的参数。

在 `spec.arguments.parameters` 中设置的值是全局作用域的，可以通过 `{{workflow.parameters.parameter_name}}` 访问。这对于将信息传递给工作流中的多个步骤非常有用。例如，如果您希望以每个容器环境中设置的不同日志级别运行工作流，您可以创建类似以下的 YAML 文件：

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: global-parameters-
spec:
  entrypoint: A
  arguments:
    parameters:
    - name: log-level
      value: INFO

  templates:
  - name: A
    container:
      image: containerA
      env:
      - name: LOG_LEVEL
        value: "{{workflow.parameters.log-level}}"
      command: [runA]
  - name: B
    container:
      image: containerB
      env:
      - name: LOG_LEVEL
        value: "{{workflow.parameters.log-level}}"
      command: [runB]
```

在这个工作流中，步骤 A 和 B 都将日志级别设置为 INFO，并且可以使用 `-p` 标志在工作流提交之间轻松更改。

### {{workflow.parameters.param_name}} 和 {{inputs.parameters.param_name}} 有什么区别?

- {{workflow.parameters.param_name}}：这种形式的参数是在工作流级别定义的，也就是说，这些参数是在整个工作流中都可以访问的。这些参数通常在工作流的 spec.arguments.parameters 部分定义，并且可以在提交工作流时通过命令行参数进行覆盖。
- {{inputs.parameters.param_name}}：这种形式的参数是在模板级别定义的，也就是说，这些参数只能在定义它们的模板中访问。这些参数通常在模板的 inputs.parameters 部分定义，并且可以通过工作流或其他模板传递给它们。

在 Argo Workflow 中，`{{workflow.parameters.param_name}}` 和 `{{inputs.parameters.param_name}}` 的使用可以通过以下例子来说明：

假设我们有一个工作流定义如下：

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: example-workflow-
spec:
  entrypoint: main
  arguments:
    parameters:
    - name: workflow-param
      value: "This is a workflow parameter"
  templates:
  - name: main
    steps:
    - - name: step-one
        template: print-message
        arguments:
          parameters:
          - name: message
            value: "{{workflow.parameters.workflow-param}}"
  - name: print-message
    inputs:
      parameters:
      - name: message
    container:
      image: alpine:latest
      command: [echo]
      args: ["{{inputs.parameters.message}}"]
```

在这个例子中，我们定义了一个工作流参数 `workflow-param`，并在 `main` 模板中的步骤 `step-one` 中使用了它。我们通过 `{{workflow.parameters.workflow-param}}` 来引用这个工作流参数，并将其值传递给 `print-message` 模板的 `message` 参数。

然后，在 `print-message` 模板中，我们定义了一个输入参数 `message`，并在容器的命令中使用了它。我们通过 `{{inputs.parameters.message}}` 来引用这个输入参数。

所以，当我们运行这个工作流时，`print-message` 模板的容器会打印出 "This is a workflow parameter"，这就是 `workflow-param` 参数的值。
