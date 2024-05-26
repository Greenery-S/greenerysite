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

Supports conditional execution. The syntax is implemented by govaluate, which provides support for complex syntax. See the following example:

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

Recursive calls between templates are allowed. See the following example. This example will continue flipping a coin until it lands heads up.

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

## 3 Retry Failed or Errored Steps

You can specify a retry strategy that determines how to retry failed or errored steps:

```yaml
# This example shows how to use retry backoff
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
        duration: "1"      # Must be a string. The default unit is seconds. It can also be a duration like "2m", "6h", "1d"
        factor: 2
        maxDuration: "1m"  # Must be a string. The default unit is seconds. It can also be a duration like "2m", "6h", "1d"
      affinity:
        nodeAntiAffinity: {}
    container:
      image: python:alpine3.6
      command: ["python", -c]
      # Has a 66% chance to fail
      args: ["import random; import sys; exit_code = random.choice([0, 1, 1]); sys.exit(exit_code)"]
```

- `limit` is the maximum number of times the container will be retried.
- `retryPolicy` specifies whether the container will be retried on failure, error, both, or only on transient errors (e.g., I/O or TLS handshake timeout). "Always" retries on both error and failure. Other options are: OnFailure (default), "OnError", and "OnTransientError" (available after v3.0.0-rc2).
- `backoff` is an exponential backoff.
- `nodeAntiAffinity` prevents steps from running on the same host. The current implementation only allows an empty nodeAntiAffinity (i.e., nodeAntiAffinity: {}), and by default, uses the label kubernetes.io/hostname as the selector.

Providing an empty retry strategy (i.e., retryStrategy::{}) will cause the container to retry until it completes.

## 4 Exit Handlers

Exit handlers are templates that are always executed at the end of a workflow, regardless of success or failure.

Common uses of exit handlers include:

- Cleaning up after the workflow runs
- Sending workflow status notifications (e.g., email/Slack)
- Posting pass/fail status to web-hook results (e.g., GitHub build results)
- Resubmitting or submitting another workflow

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

You can use the `activeDeadlineSeconds` field to limit the runtime of a workflow:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: timeouts-wf-
spec:
  activeDeadlineSeconds: 10 # Terminate the workflow after 10 seconds
  entrypoint: sleep
  templates:
  - name: sleep
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo sleeping for 1m; sleep 60; echo done"]
```

You can also limit the runtime of a specific template:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: timeouts-tpl-
spec:
  entrypoint: sleep
  templates:
  - name: sleep
    activeDeadlineSeconds: 10 # Terminate the container template after 10 seconds
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["echo sleeping for 1m; sleep 60; echo done"]
```

## 6 Suspending

Workflows can be suspended in the following ways:

```sh
argo suspend WORKFLOW
```

Or by specifying a suspend step within the workflow:

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
      duration: "20"    # Must be a string. The default unit is seconds. It can also be a duration like "2m", "6h"

  - name: argosay
    inputs:
      parameters:
      - name: message
    container:
      image: yky8/argosay:v2
      command: [ "/usr/local/bin/argosay" ]
      args: [ "echo" ,"{{inputs.parameters.message}}" ]
```

Once suspended, the workflow will not schedule any new steps until it is resumed. It can be manually resumed in the following way:

```sh
argo resume WORKFLOW
```

Or automatically resumed by setting a duration limit, as in the example above.

{{<image src="/images/argo-workflow-suspending.png" alt="argo-workflow-suspending" position="center" style="border-radius: 8px;" size="60%">}}
```sh
> argo resume suspend-template-9plrz -n argo
INFO[2024-05-26T22:10:50.883Z] Workflow to be dehydrated                     Workflow Size=3079
workflow suspend-template-9plrz resumed
```
{{<image src="/images/argo-workflow-resume.png" alt="argo-workflow-resume" position="center" style="border-radius: 8px;" size="90%">}}
