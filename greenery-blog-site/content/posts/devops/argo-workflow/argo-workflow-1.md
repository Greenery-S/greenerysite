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

A lot of examples can be found here: https://github.com/argoproj/argo-workflows/tree/main/examples
However, since the `docker/whalesay` image is no longer supported, many examples cannot run, and you need to build an image to replace it.

## 1 Argo CLI

```sh
argo submit hello-world.yaml    # submit a workflow spec to Kubernetes
argo list                       # list current workflows
argo get hello-world-xxx        # get info about a specific workflow
argo logs hello-world-xxx       # print the logs from a workflow
argo delete hello-world-xxx     # delete workflow
```

You can also use `kubectl`, but you need to specify the `namespace`.

# 2 Hello World

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
Execute `argo submit -n argo --watch hello-world.yaml`:
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
**First type: parameter comes from `-p` argument**
```shell
argo submit arguments-parameters.yaml -n argo -p message="goodbye world"
```
**Second type: parameter comes from file**
```yaml
# params.yaml
message: goodbye world
```
```shell
argo submit arguments-parameters.yaml -n argo --parameter-file params.yaml
```
**Rewrite any parameters in the spec**
Command-line arguments can also be used to override the default entry point and call any template in the workflow specification. For example, if you add a new version of the argosay template named argosay-caps, but you don't want to change the default entry point, you can call it with the following command line:

```shell
argo submit arguments-parameters.yaml -n argo --entrypoint argosay-caps
```

By combining the use of `--entrypoint` and `-p` arguments, you can call any template in the workflow specification and pass any parameters you like.

The values set in `spec.arguments.parameters` are globally scoped and can be accessed via `{{workflow.parameters.parameter_name}}`. This is very useful for passing information to multiple steps in the workflow. For example, if you want to run the workflow with different log levels set in each container environment, you can create a YAML file similar to the following:

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

In this workflow, steps A and B both set the log level to INFO, and you can easily change it between workflow submissions using the `-p` flag.

### What is the difference between {{workflow.parameters.param_name}} and {{inputs.parameters.param_name}}?

- {{workflow.parameters.param_name}}: This form of parameter is defined at the workflow level, that is, these parameters can be accessed throughout the entire workflow. These parameters are usually defined in the spec.arguments.parameters part of the workflow and can be overridden when submitting the workflow through command line parameters.
- {{inputs.parameters.param_name}}: This form of parameter is defined at the template level, that is, these parameters can only be accessed in the template where they are defined. These parameters are usually defined in the inputs.parameters part of the template and can be passed to them by the workflow or other templates.

In Argo Workflow, the use of `{{workflow.parameters.param_name}}` and `{{inputs.parameters.param_name}}` can be illustrated by the following example:

Suppose we have a workflow definition as follows:

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

In this example, we defined a workflow parameter `workflow-param` and used it in the `step-one` step of the `main` template. We reference this workflow parameter through `{{workflow.parameters.workflow-param}}` and pass its value to the `message` parameter of the `print-message` template.

Then, in the `print-message` template, we defined an input parameter `message` and used it in the container command. We reference this input parameter through `{{inputs.parameters.message}}`.

So, when we run this workflow, the container of the `print-message` template will print "This is a workflow parameter", which is the value of the `workflow-param` parameter.