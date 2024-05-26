---
title: "Argo Workflow 2"
date: 2024-05-25T14:30:03+08:00
draft: false
toc: false
images:
tags:
  - argo-workflow
categories:
  - devops
  - devops-argo-workflow
---

# Argo Workflow (2)

## 1 Steps

Multi-step workflows can be defined through the `steps` field. Each step is an independent container that can be executed in parallel.

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

As an alternative to specifying a sequence of steps, you can define a workflow as a Directed Acyclic Graph (DAG) by specifying the dependencies of each task. For complex workflows, DAGs may be easier to maintain and allow tasks to achieve maximum parallelism at runtime.

In the following workflow, step A runs first because it has no dependencies. Once A is completed, steps B and C run in parallel. Finally, once B and C are completed, step D runs.

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

### Enhanced Depends

The depends field can be enhanced, for example `depends: "A && B"` means that task D depends on tasks A and B being completed at the same time, equivalent to `depends: [A, B]`. You can also examine the final state of the task, for example `depends: "A.Succeeded"` means that task D depends on task A being successfully completed.

Here is the Markdown table you wanted:

| Task Result | Description                         | Meaning                                        |
|-------------|-------------------------------------|------------------------------------------------|
| .Succeeded  | Task Succeeded                      | Task finished with no error                    |
| .Failed     | Task Failed                         | Task exited with a non-0 exit code             |
| .Errored    | Task Errored                        | Task had an error other than a non-0 exit code |
| .Skipped    | Task Skipped                        | Task was skipped                               |
| .Omitted    | Task Omitted                        | Task was omitted                               |
| .Daemoned   | Task is Daemoned and is not Pending |                                                |

The default omitted state is the successful state, for example:

- `depends: "A"` is equivalent to `depends: "(A.Succeeded || A.Skipped || A.Daemoned)"`.
- `depends: "task || task-2.Failed"`
  is equivalent to `depends: (task.Succeeded || task.Skipped || task.Daemoned) || task-2.Failed`.

Logical operators are: `&&`,`||`,`!`.

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

## 3 Structure of Workflow Specifications

Now we have a good understanding of the basic components of a workflow specification. Let's review its basic structure:

- Kubernetes header, including metadata
- Spec body
    - Entrypoint invocation, optional arguments
    - List of template definitions
        - For each template definition
            - Name of the template
            - Optional list of inputs
            - Optional list of outputs
            - Container invocation (leaf template) or list of steps
                - For each step, template invocation

In summary, a workflow specification consists of a set of Argo templates, each of which consists of an optional input section, an optional output section, and either a container invocation or a set of steps, each of which invokes another template.

Please note that the container section of the workflow specification will accept the same options as the container section of a pod specification, including but not limited to environment variables, secrets, and volume mounts. Similarly, for volume claims and volumes.