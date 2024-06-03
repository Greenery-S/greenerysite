---
title: "Setup Local Pytorch"
date: 2024-06-04T00:31:42+08:00
draft: false
toc: false
images:
tags:
  - python
  - pytorch
  - mps
  - jupyter
categories:
  - pytorch
  - pytorch-setup
---

# 本地建设pytorch环境

## 1. 安装miniconda

可以使用pycharm自动安装,也可以手动安装.

检查是不是有jupyter notebook 和 jupyter lab

如果上面的都ok,那么就可以安装pytorch了.

## 2. 创建一个新的conda环境

```shell
conda create -n torch-gpu python=3.9
conda activate torch-gpu
```

## 3. 安装pytorch

到官网下载pytorch的安装命令 https://pytorch.org/
可以是conda/pip的命令

## 4. 将kernel注册到jupyter lab

```shell
conda install ipykernel
sudo python -m ipykernel install --name=torch-gpu
```

## 5. 打开jupyter lab

```shell
jupyter lab
```

## 6. 测试pytorch (apple silicon m1)

选取注册的kernel,然后运行代码:

test1.py
```python
import torch
import math
# this ensures that the current MacOS version is at least 12.3+
print(torch.backends.mps.is_available())
# this ensures that the current current PyTorch installation was built with MPS activated.
print(torch.backends.mps.is_built())
```

test2.py
```python
dtype = torch.float
device = torch.device("mps")
# Create random input and output data
x = torch.linspace(-math.pi, math.pi, 2000, device=device, dtype=dtype)
y = torch.sin(x)

# Randomly initialize weights
a = torch.randn((), device=device, dtype=dtype)
b = torch.randn((), device=device, dtype=dtype)
c = torch.randn((), device=device, dtype=dtype)
d = torch.randn((), device=device, dtype=dtype)

learning_rate = 1e-6
for t in range(2000):
    # Forward pass: compute predicted y
    y_pred = a + b * x + c * x ** 2 + d * x ** 3

    # Compute and print loss
    loss = (y_pred - y).pow(2).sum().item()
    if t % 100 == 99:
        print(t, loss)

# Backprop to compute gradients of a, b, c, d with respect to loss
    grad_y_pred = 2.0 * (y_pred - y)
    grad_a = grad_y_pred.sum()
    grad_b = (grad_y_pred * x).sum()
    grad_c = (grad_y_pred * x ** 2).sum()
    grad_d = (grad_y_pred * x ** 3).sum()

    # Update weights using gradient descent
    a -= learning_rate * grad_a
    b -= learning_rate * grad_b
    c -= learning_rate * grad_c
    d -= learning_rate * grad_d


print(f'Result: y = {a.item()} + {b.item()} x + {c.item()} x^2 + {d.item()} x^3')
```