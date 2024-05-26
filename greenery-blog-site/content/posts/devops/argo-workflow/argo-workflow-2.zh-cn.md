---
title: "Argo Workflow 2"
date: 2024-05-25T14:30:03+08:00
draft: false
toc: false
images:
tags:
  - argo-workflow
  - steps
  - DAG
categories:
  - devops
  - devops-argo-workflow
---

# Argo Workflow (2)

## 1 Steps

多步骤的工作流可以通过`steps`字段来定义。每个步骤都是一个独立的容器，可以并行执行。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: steps-
spec:
  entrypoint: hello-hello-hello

  # This spec contains two templates: hello-hello-hello and whalesay
  templates:
    - name: hello-hello-hello
      # Instead of just running a container
      # This template has a sequence of steps
      steps:
        - - name: hello1            # hello1 is run before the following steps
            template: argosay
            arguments:
              parameters:
                - name: message
                  value: "hello1"
        - - name: hello2a           # double dash => run after previous step
            template: argosay
            arguments:
              parameters:
                - name: message
                  value: "hello2a"
          - name: hello2b           # single dash => run in parallel with previous step
            template: argosay
            arguments:
              parameters:
                - name: message
                  value: "hello2b"

    # This is the same template as from the previous example
    - name: argosay
      inputs:
        parameters:
          - name: message
      container:
        image: yky8/argosay:v2
        command: [ "/usr/local/bin/argosay" ]
        args: [ "echo","{{inputs.parameters.message}}" ]
```

```shell
argo submit multi-steps.yaml -n argo --watch
```

```text
Name:                steps-kl27q
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Sat May 25 14:44:26 +0800 (20 seconds ago)
Started:             Sat May 25 14:44:26 +0800 (20 seconds ago)
Finished:            Sat May 25 14:44:46 +0800 (now)
Duration:            20 seconds
Progress:            3/3
ResourcesDuration:   0s*(1 cpu),6s*(100Mi memory)

STEP            TEMPLATE           PODNAME                         DURATION  MESSAGE
 ✔ steps-kl27q  hello-hello-hello
 ├───✔ hello1   argosay            steps-kl27q-argosay-3962065941  3s
 └─┬─✔ hello2a  argosay            steps-kl27q-argosay-3285575750  3s
   └─✔ hello2b  argosay            steps-kl27q-argosay-3268798131  3s
```

## 2 DAG

作为指定步骤序列的替代方案,您可以通过指定每个任务的依赖关系,将工作流定义为有向无环图(DAG)
.对于复杂的工作流,DAGs可能更容易维护,并且允许任务在运行时达到最大的并行性.

在以下工作流中,步骤 A 首先运行,因为它没有依赖关系.一旦 A 完成,步骤 B 和 C 并行运行.最后,一旦 B 和 C 完成,步骤 D 运行.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-diamond-
spec:
  entrypoint: diamond
  templates:
    - name: echo
      inputs:
        parameters:
          - name: message
      container:
        image: alpine:3.7
        command: [ echo, "{{inputs.parameters.message}}" ]
    - name: diamond
      dag:
        tasks:
          - name: A
            template: echo
            arguments:
              parameters: [ { name: message, value: A } ]
          - name: B
            dependencies: [ A ]
            template: echo
            arguments:
              parameters: [ { name: message, value: B } ]
          - name: C
            dependencies: [ A ]
            template: echo
            arguments:
              parameters: [ { name: message, value: C } ]
          - name: D
            dependencies: [ B, C ]
            template: echo
            arguments:
              parameters: [ { name: message, value: D } ]
```

```shell
argo submit dag.yaml -n argo --watch
```

{{<image src="/images/argo-workflow-dag.png" alt="argo-workflow-dag" position="center" style="border-radius: 0px; width: 30%;" >}}

### 加强的Depends

depend字段可以加强, 例如`depends: "A && B"`表示任务D依赖于任务A和任务B同时完成,等价于`depends: [A, B]`.
还可以考察task的终态,例如`depends: "A.Succeeded"`表示任务D依赖于任务A成功完成.

这是您要的 Markdown 表格：

| Task Result | Description                         | Meaning                                        |
|-------------|-------------------------------------|------------------------------------------------|
| .Succeeded  | Task Succeeded                      | Task finished with no error                    |
| .Failed     | Task Failed                         | Task exited with a non-0 exit code             |
| .Errored    | Task Errored                        | Task had an error other than a non-0 exit code |
| .Skipped    | Task Skipped                        | Task was skipped                               |
| .Omitted    | Task Omitted                        | Task was omitted                               |
| .Daemoned   | Task is Daemoned and is not Pending |                                                |

默认省略状态就是成功状态, 例如:

- `depends: "A"`等价于`depends: "(A.Succeeded || A.Skipped || A.Daemoned)"`.
- `depends: "task || task-2.Failed"`
  等价于 `depends: (task.Succeeded || task.Skipped || task.Daemoned) || task-2.Failed`.

逻辑运算符有: `&&`,`||`,`!`.

### multi-root DAG

```yaml
# The following workflow executes a multi-root workflow
# 
#   A   B
#  / \ /
# C   D
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-multiroot-
spec:
  entrypoint: multiroot
  templates:
    - name: echo
      inputs:
        parameters:
          - name: message
      container:
        image: alpine:3.7
        command: [ echo, "{{inputs.parameters.message}}" ]
    - name: multiroot
      dag:
        tasks:
          - name: A
            template: echo
            arguments:
              parameters: [ { name: message, value: A } ]
          - name: B
            template: echo
            arguments:
              parameters: [ { name: message, value: B } ]
          - name: C
            depends: "A"
            template: echo
            arguments:
              parameters: [ { name: message, value: C } ]
          - name: D
            depends: "A && B"
            template: echo
            arguments:
              parameters: [ { name: message, value: D } ]
```

```shell
argo submit multi-root-dag.yaml -n argo --watch
```

{{<image src="/images/argo-workflow-multi-root.png" alt="argo-workflow-multiroot-dag" position="center" style="border-radius: 0px; width: 40%;" >}}

## 3 工作流规范的结构

现在我们已经对工作流规范的基本组成部分有了足够的了解。回顾一下其基本结构：

- Kubernetes头部，包括元数据
- 规范主体
    - 入口点调用，可选参数
    - 模板定义列表
        - 对于每个模板定义
            - 模板的名称
            - 可选的输入列表
            - 可选的输出列表
            - 容器调用（叶模板）或步骤列表
                - 对于每个步骤，模板调用

总结一下，工作流规范由一组 Argo 模板组成，每个模板由一个可选的输入部分、一个可选的输出部分以及**一个容器调用**或**一组步骤组成**，**每个步骤都调用另一个模板**。

请注意，工作流规范的容器部分将接受与 pod 规范的容器部分相同的选项，包括但不限于环境变量、秘密和卷挂载。同样，对于卷声明和卷。



