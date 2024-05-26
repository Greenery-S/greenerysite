---
title: "Argo Workflow 3"
date: 2024-05-25T17:14:53+08:00
draft: false
toc: false
images:
tags:
  - argo-workflow
  - Artifacts
categories:
  - devops
  - devops-argo-workflow
---

# Argo Workflow (3)

## 1 Artifacts

在运行工作流时，步骤生成或使用工件是非常常见的情况。通常，一个步骤的输出工件可能会被后续步骤作为输入工件使用。

下面的工作流规范包含两个按顺序运行的步骤。第一个名为 generate-artifact 的步骤将使用 argosay 模板生成一个工件，该工件将被第二个名为 print-message 的步骤使用，print-message 将消费生成的工件。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: artifact-passing-
spec:
  entrypoint: artifact-example
  templates:
  - name: artifact-example
    steps:
    - - name: generate-artifact
        template: argosay
    - - name: consume-artifact
        template: print-message
        arguments:
          artifacts:
          # bind message to the hello-art artifact
          # generated by the generate-artifact step
          - name: message
            from: "{{steps.generate-artifact.outputs.artifacts.hello-art}}"

  - name: argosay
    container:
      image: yky8/argosay:v2
      # sh -c，你可以在其后面提供一个字符串，
      # 这个字符串将被 sh 作为一个完整的 shell 命令来执行
      command: [sh, -c]
      # The tee command is used in Linux and Unix systems. 
      # It reads from the standard input and writes to both standard output and one or more files simultaneously. 
      # This can be useful when you want to save the output of a command to a file while also viewing it in the terminal.
      args: ["/usr/local/bin/argosay echo 'hello world' | tee /tmp/hello_world.txt"]
    outputs:
      artifacts:
      # generate hello-art artifact from /tmp/hello_world.txt
      # artifacts can be directories as well as files
      - name: hello-art # 被 consume-artifact 步骤使用,"from"字段指定
        path: /tmp/hello_world.txt

  - name: print-message
    inputs:
      artifacts:
      # unpack the message input artifact
      # and put it at /tmp/message
      - name: message
        path: /tmp/message # put it at /tmp/message
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["cat /tmp/message"]
```

```shell
argo submit artifacts.yaml -n argo
```
{{<image src="/images/argo-workflow-artifacts.png" alt="argo-workflow-artifacts" position="center" style="border-radius: 0px; width: 30%;" >}}

### 对于过大的工件Artifact

在运行工作流时，步骤生成或使用工件是非常常见的情况。通常，一个步骤的输出工件可能会被后续步骤作为输入工件使用。

```yaml
<... snipped ...>
  - name: print-large-artifact
    # below patch gets merged with the actual pod spec and increses the memory
    # request of the init container.
    podSpecPatch: |
      initContainers:
        - name: init
          resources:
            requests:
              memory: 2Gi
              cpu: 300m
    inputs:
      artifacts:
      - name: data
        path: /tmp/large-file
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["cat /tmp/large-file"]
<... snipped ...>
```

### 工件打包策略

在 Argo Workflows 中，工件默认被打包为 Tarball 并进行 gzip 压缩。您可以通过指定存档策略（archive strategy）来自定义此行为。以下是一个示例，展示了如何使用 archive 字段来自定义工件的存档策略：

```yaml
<... snipped ...>
    outputs:
      artifacts:
        # default behavior - tar+gzip default compression.
      - name: hello-art-1
        path: /tmp/hello_world.txt

        # disable archiving entirely - upload the file / directory as is.
        # this is useful when the container layout matches the desired target repository layout.   
      - name: hello-art-2
        path: /tmp/hello_world.txt
        archive:
          none: {}

        # customize the compression behavior (disabling it here).
        # this is useful for files with varying compression benefits, 
        # e.g. disabling compression for a cached build workspace and large binaries, 
        # or increasing compression for "perfect" textual data - like a json/xml export of a large database.
      - name: hello-art-3
        path: /tmp/hello_world.txt
        archive:
          tar:
            # no compression (also accepts the standard gzip 1 to 9 values)
            compressionLevel: 0
<... snipped ...>
```
### 工件的垃圾收集
存储引擎支持,文档: https://argo-workflows.readthedocs.io/en/latest/configure-artifact-repository/

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: artifact-gc-
spec:
  entrypoint: main
  artifactGC:
    strategy: OnWorkflowDeletion  # default Strategy set here applies to all Artifacts by default
  templates:
    - name: main
      container:
        image: argoproj/argosay:v2
        command:
          - sh
          - -c
        args:
          - |
            echo "can throw this away" > /tmp/temporary-artifact.txt
            echo "keep this" > /tmp/keep-this.txt
      outputs:
        artifacts:
          - name: temporary-artifact
            path: /tmp/temporary-artifact.txt
            s3:
              key: temporary-artifact.txt
          - name: keep-this
            path: /tmp/keep-this.txt
            s3:
              key: keep-this.txt
            artifactGC:
              strategy: Never   # optional override for an Artifact
```

### 工件命名建议--参数化

如果有可能存在并发运行的相同工作流，那么应该考虑使用参数化的S3键，例如使用`{{workflow.uid}}`等。这样做的目的是为了避免一个工作流正在删除一个工件，而另一个工作流正在为同一个S3键生成工件的情况。

例如，假设你有两个并发运行的工作流，它们都使用相同的S3键来存储工件。如果一个工作流完成并删除了它的工件，而另一个工作流还在生成工件，那么可能会出现问题。因为第二个工作流可能会发现它的工件已经被删除，或者它可能会覆盖第一个工作流的工件。

为了避免这种情况，你可以使用参数化的S3键，这样每个工作流都会有一个唯一的S3键。例如，你可以使用`{{workflow.uid}}`作为S3键的一部分，这样每个工作流都会有一个唯一的S3键，因为每个工作流的`uid`都是唯一的。

### 存储服务的服务账号或IAM注释

如果要使用存储服务的服务账号或IAM注释，可以在工作流规范中指定这些注释。这些注释将被传递给存储服务，以便存储服务可以使用这些注释来控制对存储桶的访问。

可以改整个workflow的存储服务的服务账号或IAM注释，也可以为每个工件指定不同的服务账号或IAM注释。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: artifact-gc-
spec:
  entrypoint: main
  artifactGC:
    strategy: OnWorkflowDeletion 
    ##############################################################################################
    #    Workflow Level Service Account and Metadata
    ##############################################################################################
    serviceAccountName: my-sa
    podMetadata:
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/my-iam-role
  templates:
    - name: main
      container:
        image: argoproj/argosay:v2
        command:
          - sh
          - -c
        args:
          - |
            echo "can throw this away" > /tmp/temporary-artifact.txt
            echo "keep this" > /tmp/keep-this.txt
      outputs:
        artifacts:
          - name: temporary-artifact
            path: /tmp/temporary-artifact.txt
            s3:
              key: temporary-artifact-{{workflow.uid}}.txt
            artifactGC:
              ####################################################################################
              #    Optional override capability
              ####################################################################################
              serviceAccountName: artifact-specific-sa
              podMetadata:
                annotations:
                  eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/artifact-specific-iam-role
          - name: keep-this
            path: /tmp/keep-this.txt
            s3:
              key: keep-this-{{workflow.uid}}.txt
            artifactGC:
              strategy: Never
```
要支持自建服务账号,需要创建Role和RoleBinding,并将Role绑定到ServiceAccount上:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    workflows.argoproj.io/description: |
      This is the minimum recommended permissions needed if you want to use artifact GC.
  name: artifactgc
rules:
- apiGroups:
  - argoproj.io
  resources:
  - workflowartifactgctasks
  verbs:
  - list
  - watch
- apiGroups:
  - argoproj.io
  resources:
  - workflowartifactgctasks/status
  verbs:
  - patch
```
如果你使用了快速启动的manifest文件进行安装，那么你会得到一个名为artifactgc的角色（Role）。如果你使用的是发布版本的install.yaml文件进行安装，那么同样的权限会在argo-cluster-role中。  

如果你没有使用自己的ServiceAccount，而是使用默认的ServiceAccount，那么你需要创建一个RoleBinding或ClusterRoleBinding，将artifactgc角色或argo-cluster-role绑定到默认的ServiceAccount上。这样，当Argo Workflow运行时，它就可以使用这些角色的权限。

### Argo Workflow中的垃圾收集（Garbage Collection，GC）失败时会发生什么?

如果由于某种原因（除了工件已经被删除，这不被视为失败）删除工件失败，工作流的状态将被标记为新的条件，以指示"Artifact GC Failure"。同时，Kubernetes会发出一个事件，Argo Server UI也会显示失败信息。为了进一步调试，用户应该找到一个或多个名为`<wfName>-artgc-*`的Pod，并查看其日志。

如果用户需要删除工作流及其子CRD对象，他们需要修补工作流以删除阻止删除的终结器（finalizer）：

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
finalizers:
  - workflows.argoproj.io/artifact-gc
```

可以通过以下命令删除终结器：

```shell
kubectl patch workflow my-wf \
    --type json \
    --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
```

或者为了简化操作，可以使用Argo CLI的`argo delete`命令并带上`--force`标志，这在底层会在执行删除操作前移除终结器。

在3.5及更高版本的发布版本中，Workflow Spec中添加了一个名为`forceFinalizerRemoval`的标志，即使Artifact GC失败，也可以强制移除终结器：

```yaml
spec:
  artifactGC:
    strategy: OnWorkflowDeletion 
    forceFinalizerRemoval: true
```
这意味着，即使工件的垃圾收集失败，也可以强制删除工作流。

## 2 内置工件

有一些非常常见的工件类型，Argo Workflows提供了内置支持。这些工件类型包括：git仓库,http资源,GCS存储桶,S3存储桶的支持. 当然,你可以用任何容器做任何事情,但是这些内置工件类型可以让你更容易地使用这些常见的工件类型。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hardwired-artifact-
spec:
  entrypoint: hardwired-artifact
  templates:
    - name: hardwired-artifact
      podSpecPatch: |
        initContainers:
          - name: init
            resources:
              requests:
                memory: 2Gi
                cpu: 300m
      inputs:
        artifacts:
          # Check out the main branch of the argo repo and place it at /src
          # revision can be anything that git checkout accepts: branch, commit, tag, etc.
          - name: argo-source
            path: /src
            git:
              repo: https://github.com/argoproj/argo-workflows.git
              revision: "main"
          # Download kubectl 1.8.0 and place it at /bin/kubectl
          - name: kubectl
            path: /bin/kubectl
            mode: 0755
            http:
              url: https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl
        # Copy an s3 compatible artifact repository bucket (such as AWS, GCS and MinIO) and place it at /s3
        # - name: objects
        #   path: /s3
        #   s3:
        #     endpoint: storage.googleapis.com
        #     bucket: my-bucket-name
        #     key: path/in/bucket
        #     accessKeySecret:
        #       name: my-s3-credentials
        #       key: accessKey
        #     secretKeySecret:
        #       name: my-s3-credentials
        #       key: secretKey
      container:
        image: debian
        command: [sh, -c]
        args: ["ls -l /src /bin/kubectl"] # /s3 is not tested here
```

这些是Argo Workflow中的工件（Artifacts）的使用示例。工件是在工作流执行过程中生成或使用的文件或目录。在这个例子中，工作流的模板定义了三个输入工件：

1. `argo-source`：这个工件使用git类型，它会从指定的git仓库（在这个例子中是https://github.com/argoproj/argo-workflows.git）检出指定的版本（在这个例子中是"main"分支），并将其放在`/src`目录下。

2. `kubectl`：这个工件使用HTTP类型，它会从指定的URL（在这个例子中是https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl）下载文件，并将其放在`/bin/kubectl`。`mode: 0755`表示这个文件将被设置为可执行。

3. `objects`：这个工件使用S3类型，它会从指定的S3兼容的存储服务（在这个例子中是storage.googleapis.com）的指定存储桶（在这个例子中是`my-bucket-name`）和键（在这个例子中是`path/in/bucket`）下载文件或目录，并将其放在`/s3`目录下。`accessKeySecret`和`secretKeySecret`字段指定了存储AWS访问密钥和秘密密钥的Kubernetes secrets。

然后，这个模板定义了一个容器，这个容器会运行一个命令来列出`/src`、`/bin/kubectl`和`/s3`目录的内容，这些目录就是上面定义的输入工件被放置的地方。


## 3 Script

有时候我们想让工作流执行一些脚本，而不是直接运行一个容器。这时候我们可以使用`script`类型的工件。`script`类型的工件是一个脚本，它可以是一个shell脚本、Python脚本、Perl脚本、Ruby脚本等等。在这个例子中，我们将展示如何使用`script`类型的工件。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: scripts-
spec:
  entrypoint: bash-script-example
  templates:
  - name: bash-script-example
    steps:
    - - name: generate-from-bash
        template: gen-random-int-bash
      - name: generate-from-python
        template: gen-random-int-python
      - name: generate-from-javascript
        template: gen-random-int-javascript
    - - name: print-for-bash
        template: print-message
        arguments:
          parameters:
          - name: message
            value: "[BASH] {{steps.generate-from-bash.outputs.result}}"  # The result of the here-script
      - name: print-for-python
        template: print-message
        arguments:
          parameters:
          - name: message
            value: "[PY] {{steps.generate-from-python.outputs.result}}"  # The result of the Python script
      - name: print-for-javascript
        template: print-message
        arguments:
          parameters:
          - name: message
            value: "[JS] {{steps.generate-from-javascript.outputs.result}}"  # The result of the JavaScript script

  - name: gen-random-int-bash
    script:
      image: debian:9.4
      command: [bash]
      source: |                                         # Contents of the here-script
        cat /dev/urandom | od -N2 -An -i | awk -v f=1 -v r=100 '{printf "%i\n", f + r * $1 / 65536}'

  - name: gen-random-int-python
    script:
      image: python:alpine3.6
      command: [python]
      source: |
        import random
        i = random.randint(1, 100)
        print(i)

  - name: gen-random-int-javascript
    script:
      image: node:9.1-alpine
      command: [node]
      source: |
        var rand = Math.floor(Math.random() * 100);
        console.log(rand);

  - name: print-message
    inputs:
      parameters:
      - name: message
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo result was: {{inputs.parameters.message}}"]
```
"script"关键字允许**使用"source"标签来指定脚本体**。这将创建一个包含脚本体的临时文件，然后将**临时文件的名称作为最后一个参数传递给"command"**，"command"应该是一个执行脚本体的解释器。

使用"script"特性还会将**运行脚本的标准输出分配给一个名为"result"的特殊输出参数**。这允许你在工作流规范的其余部分中使用运行脚本本身的结果。在这个例子中，结果简单地被"print-message"模板回显。

```shell
argo submit scripts-parallel.yaml -n argo --watch
```
{{<image src="/images/argo-workflow-scripts-parallel.png" alt="argo-workflow-script" position="center" style="border-radius: 0px; width: 50%;" >}}

## 4 Outputs Parameters

输出参数提供了一种通用机制,可以将步骤的结果用作参数(而不仅仅是作为工件).这允许你使用任何类型步骤的结果,而不仅仅是脚本. 用于条件测试,循环和参数. 输出参数的工作方式类似于脚本结果,只是输出参数的值被设置为生成的文件的内容,而不是stdout的内容.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: output-parameter-
spec:
  entrypoint: output-parameter
  templates:
    - name: output-parameter
      steps:
        - - name: generate-parameter
            template: argosay
        - - name: consume-parameter
            template: print-message
            arguments:
              parameters:
                # Pass the hello-param output from the generate-parameter step as the message input to print-message
                - name: message
                  value: "{{steps.generate-parameter.outputs.parameters.hello-param}}"

    - name: argosay
      container:
        image: yky8/argosay:v2
        command: [ sh, -c ]
        args: [ "echo -n hello world > /tmp/hello_world.txt" ]  # generate the content of hello_world.txt
      outputs:
        parameters:
          - name: hello-param  # name of output parameter
            valueFrom:
              path: /tmp/hello_world.txt # set the value of hello-param to the contents of this hello-world.txt

    - name: print-message
      inputs:
        parameters:
          - name: message
      container:
        image: yky8/argosay:v2
        command: [ "/usr/local/bin/argosay" ]
        args: [ "echo","{{inputs.parameters.message}}" ]
```

这里拿取step的输出参数作为输入参数,而不是工件.这个例子中,`generate-parameter`步骤生成一个名为`hello-param`的输出参数,然后`consume-parameter`步骤将这个输出参数作为输入参数传递给`print-message`步骤。

如果是dag的话,可以使用`{{tasks.generate-parameter.outputs.parameters.hello-param}}`来获取输出参数.

```shell
argo submit output-params.yaml -n argo --watch
```
### `outputs.result`捕获标准输出

只有标准输出流的256 kb会被捕获.

- script的输出就是用过`outputs.result`来捕获的.可以参考上一节的内容.

- 容器Steps和Tasks的标准输出也会被捕获并存储在结果参数中.
  - 例如,如果有一个名为 log-int 的任务,那么它的结果可以通过 {{ tasks.log-int.outputs.result }} 来访问. 如果你在使用步骤,那么可以将 tasks 替换为 steps,即 {{ steps.log-int.outputs.result }}.这样,你就可以在工作流的其他部分使用这个步骤或任务的输出结果.

