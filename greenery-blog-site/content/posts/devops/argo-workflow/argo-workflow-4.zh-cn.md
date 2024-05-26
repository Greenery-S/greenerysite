---
title: "Argo Workflow 4"
date: 2024-05-25T22:25:36+08:00
draft: false
toc: false
images:
tags:
  - argo-workflow
  - secret
  - volume
categories:
  - devops
  - devops-argo-workflow
---

# Argo Workflow (4) 

## 1 Secrets

Argo Workflow支持在workflow中使用Kubernetes的Secret。Secret是一种用来存储敏感信息的对象，比如密码、OAuth令牌等。Secret可以以明文或base64编码的形式存储在Etcd中。在workflow中使用Secret时，需要在workflow的spec中定义一个`secrets`字段，然后在workflow的template中使用`{{workflow.spec.secrets}}`引用。

先创建一个secret，然后在workflow中使用这个secret。

```shell
kubectl create secret generic my-secret --from-literal=mypassword=S00perS3cretPa55word -n argo
```
```yaml
# To run this example, first create the secret by running:
# kubectl create secret generic my-secret --from-literal=mypassword=S00perS3cretPa55word
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: secret-example-
spec:
  entrypoint: argosay
  # To access secrets as files, add a volume entry in spec.volumes[] and
  # then in the container template spec, add a mount using volumeMounts.
  volumes:
  - name: my-secret-vol
    secret:
      secretName: my-secret     # name of an existing k8s secret
  templates:
  - name: argosay
    container:
      image: alpine:3.7
      command: [sh, -c]
      args: ['
        echo "secret from env: $MYSECRETPASSWORD";
        echo "secret from file: `cat /secret/mountpath/mypassword`"
      ']
      # To access secrets as environment variables, use the k8s valueFrom and
      # secretKeyRef constructs.
      env:
      - name: MYSECRETPASSWORD  # name of env var
        valueFrom:
          secretKeyRef:
            name: my-secret     # name of an existing k8s secret
            key: mypassword     # 'key' subcomponent of the secret
      volumeMounts:
      - name: my-secret-vol     # mount file containing secret at /secret/mountpath
        mountPath: "/secret/mountpath"
```

## 2 Volumes

一下例子会动态创建一个volume,然后在2步的workflow中使用这个volume.

pv是一个持久卷，pvc是一个持久卷声明，pv和pvc是k8s中的两个资源对象。pv是一个持久卷的实际对象，pvc是一个持久卷的声明对象。pv是一个集群级别的资源，pvc是一个命名空间级别的资源。pv是一个持久卷的实际对象，pvc是一个持久卷的声明对象。pv是一个集群级别的资源，pvc是一个命名空间级别的资源。

这里的pvc是临时存在的,workflow结束后会被删除.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: volumes-pvc-
spec:
  entrypoint: volumes-pvc-example
  volumeClaimTemplates:                 # define volume, same syntax as k8s Pod spec
  - metadata:
      name: workdir                     # name of volume claim
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi                  # Gi => 1024 * 1024 * 1024

  templates:
  - name: volumes-pvc-example
    steps:
    - - name: generate
        template: argosay
    - - name: print
        template: print-message

  - name: argosay
    container:
      image: yky8/argosay:v2
      command: [sh, -c]
      args: ["echo generating message in volume; cowsay hello world | tee /mnt/vol/hello_world.txt"]
      # Mount workdir volume at /mnt/vol before invoking docker/whalesay
      volumeMounts:                     # same syntax as k8s Pod spec
      - name: workdir
        mountPath: /mnt/vol

  - name: print-message
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo getting message from volume; find /mnt/vol; cat /mnt/vol/hello_world.txt"]
      # Mount workdir volume at /mnt/vol before invoking docker/whalesay
      volumeMounts:                     # same syntax as k8s Pod spec
      - name: workdir
        mountPath: /mnt/vol
```
Volume 是一种非常有效的方式,可以将大量数据从工作流的一个步骤移动到另一个步骤.根据系统的不同,一些卷可能可以从多个步骤同时访问.

有些时候,我们想要去获取已经存在的卷,而不是动态创建一个新的卷:

```yaml
# Define Kubernetes PVC
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: my-existing-volume
spec:
  accessModes: [ "ReadWriteOnce" ]
  resources:
    requests:
      storage: 1Gi
```
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: volumes-existing-
spec:
  entrypoint: volumes-existing-example
  volumes:
  # Pass my-existing-volume as an argument to the volumes-existing-example template
  # Same syntax as k8s Pod spec
  - name: workdir
    persistentVolumeClaim:
      claimName: my-existing-volume

  templates:
  - name: volumes-existing-example
    steps:
    - - name: generate
        template: argosay
    - - name: print
        template: print-message

  - name: argosay
    container:
      image: yky8/argosay:v2
      command: [sh, -c]
      args: ["echo generating message in volume; cowsay hello world | tee /mnt/vol/hello_world.txt"]
      volumeMounts:
      - name: workdir
        mountPath: /mnt/vol

  - name: print-message
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo getting message from volume; find /mnt/vol; cat /mnt/vol/hello_world.txt"]
      volumeMounts:
      - name: workdir
        mountPath: /mnt/vol
```
也可以在workflow的template字段下使用**resource**步骤来定义volume,这样可以在workflow的spec字段下定义volume,然后在workflow的template中使用这个volume.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: template-level-volume-
spec:
  entrypoint: generate-and-use-volume
  templates:
  - name: generate-and-use-volume
    steps:
    - - name: generate-volume
        template: generate-volume
        arguments:
          parameters:
            - name: pvc-size
              # In a real-world example, this could be generated by a previous workflow step.
              value: '1Gi'
    - - name: generate
        template: argosay
        arguments:
          parameters:
            - name: pvc-name
              value: '{{steps.generate-volume.outputs.parameters.pvc-name}}'
    - - name: print
        template: print-message
        arguments:
          parameters:
            - name: pvc-name
              value: '{{steps.generate-volume.outputs.parameters.pvc-name}}'

  - name: generate-volume
    inputs:
      parameters:
        - name: pvc-size
    resource:
      action: create
      setOwnerReference: true
      manifest: |
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          generateName: pvc-example-
        spec:
          accessModes: ['ReadWriteOnce', 'ReadOnlyMany']
          resources:
            requests:
              storage: '{{inputs.parameters.pvc-size}}'
    outputs:
      parameters:
        - name: pvc-name
          valueFrom:
            jsonPath: '{.metadata.name}'

  - name: argosay
    inputs:
      parameters:
        - name: pvc-name
    volumes:
      - name: workdir
        persistentVolumeClaim:
          claimName: '{{inputs.parameters.pvc-name}}'
    container:
      image: yky8/argosay:v2
      command: [sh, -c]
      args: ["echo generating message in volume; cowsay hello world | tee /mnt/vol/hello_world.txt"]
      volumeMounts:
      - name: workdir
        mountPath: /mnt/vol

  - name: print-message
    inputs:
        parameters:
          - name: pvc-name
    volumes:
      - name: workdir
        persistentVolumeClaim:
          claimName: '{{inputs.parameters.pvc-name}}'
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo getting message from volume; find /mnt/vol; cat /mnt/vol/hello_world.txt"]
      volumeMounts:
      - name: workdir
        mountPath: /mnt/vol
```
如果要执行这个,需要先确定argo的namespace下有default service account的权限,否则会报错.

像我这个开始是没有pvc创建权限的,需要给default service account添加权限.

```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: argo
  name: pvc-creator
rules:
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["create", "delete", "get", "list", "watch"]
---
# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pvc-creator-binding
  namespace: argo
subjects:
- kind: ServiceAccount
  name: default
  namespace: argo
roleRef:
  kind: Role
  name: pvc-creator
  apiGroup: rbac.authorization.k8s.io
```

```shell
kubectl apply -f role_bind.yaml
argo submit volume-tpl.yaml -n argo
```

{{<image src="/images/argo-workflow-pvc-tpl.png" alt="argo-workflow-tpl" position="center" style="border-radius: 0px; width: 80%;">}}