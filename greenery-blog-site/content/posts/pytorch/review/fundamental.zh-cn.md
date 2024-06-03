---
title: "Fundamental"
date: 2024-06-04T00:05:06+08:00
draft: false
toc: false
images:
tags:
  - python
  - pytorch
categories:
  - pytorch
  - pytorch-review
---

# fundamentals


```python
import torch

torch.__version__
```




    '2.4.0.dev20240602'



## 1 Tensor

#TODO: 读文档 [`torch.Tensor`](https://pytorch.org/docs/stable/tensors.html)

### 1.1 scalar


```python
scalar = torch.tensor(9)
scalar
```




    tensor(9)




```python
scalar.ndim, scalar.ndimension()
```




    (0, 0)




```python
scalar.item()
```




    9



### 1.2 vector


```python
vector = torch.tensor([9, 9, 9])
vector
```




    tensor([9, 9, 9])




```python
vector.ndim
```




    1




```python
vector.shape
```




    torch.Size([3])



### 1.3 matrix


```python
matrix = torch.tensor([[9, 9, 9],
                       [9, 9, 9]])
matrix
```




    tensor([[9, 9, 9],
            [9, 9, 9]])




```python
matrix.ndim
```




    2




```python
matrix.shape
```




    torch.Size([2, 3])




```python
matrix.size()
```




    torch.Size([2, 3])



### 1.4 tensor


```python
tensor = torch.tensor(
    [  #dim0, 这对括号里面有两个matrix
        [  #dim1, 这对括号里面有三个vector
            [  #dim2, 这对括号里面有三个scalar
                1,
                2,
                3,
            ],
            [1, 2, 3],
            [1, 2, 3]
        ],
        [  #dim1
            [1, 2, 3],
            [1, 2, 3],
            [1, 2, 3]
        ]
    ]
)
tensor
```




    tensor([[[1, 2, 3],
             [1, 2, 3],
             [1, 2, 3]],
    
            [[1, 2, 3],
             [1, 2, 3],
             [1, 2, 3]]])




```python
tensor.ndim
```




    3




```python
tensor.shape
```




    torch.Size([2, 3, 3])



## 2 random tensor


```python
ramdom_tensor = torch.rand(size=(3, 4))
ramdom_tensor, ramdom_tensor.dtype
```




    (tensor([[0.9508, 0.0344, 0.1949, 0.2121],
             [0.6301, 0.8800, 0.0905, 0.8551],
             [0.1719, 0.8458, 0.5306, 0.7635]]),
     torch.float32)




```python
random_image_size_tensor = torch.rand(size=(224, 224, 3))
random_image_size_tensor.shape, random_image_size_tensor.ndim
```




    (torch.Size([224, 224, 3]), 3)



## 3 zeros and ones


```python
zeros = torch.zeros(size=(3, 4))
zeros, zeros.dtype
```




    (tensor([[0., 0., 0., 0.],
             [0., 0., 0., 0.],
             [0., 0., 0., 0.]]),
     torch.float32)




```python
ones = torch.ones(size=(3, 4))
ones, ones.dtype
```




    (tensor([[1., 1., 1., 1.],
             [1., 1., 1., 1.],
             [1., 1., 1., 1.]]),
     torch.float32)




```python
# Use torch.arange(), torch.range() is deprecated 
zero_to_ten_deprecated = torch.range(0, 10)

zero_to_ten = torch.arange(start=0, end=10, step=1)
zero_to_ten
```

    /var/folders/jw/r2366h9x7y99tvnxp8fzcrdh0000gn/T/ipykernel_18720/2515304713.py:2: UserWarning: torch.range is deprecated and will be removed in a future release because its behavior is inconsistent with Python's range builtin. Instead, use torch.arange, which produces values in [start, end).
      zero_to_ten_deprecated = torch.range(0, 10)





    tensor([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])




```python
ten_zeros = torch.zeros_like(input=zero_to_ten)
ten_zeros
```




    tensor([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])



## 4 tensor data type


```python
float_32_tensor = torch.tensor([1, 2, 3],
                               dtype=None,  # default is float32
                               device=None,  # default is cpu
                               requires_grad=False,
                               # if True, the tensor will keep track of the operations that created it
                               )
float_32_tensor.shape, float_32_tensor.dtype, float_32_tensor.device, float_32_tensor.requires_grad
```




    (torch.Size([3]), torch.int64, device(type='cpu'), False)




```python
float_16_tensor = torch.tensor([3.0, 6.0, 9.0],
                               dtype=torch.float16)  # torch.half would also work

float_16_tensor.dtype
```




    torch.float16



## 5 tensor operations

These operations are often a wonderful dance between:
* Addition
* Substraction
* Multiplication (element-wise)
* Division
* Matrix multiplication

### 5.1 basic operations


```python
tensor = torch.tensor([1, 2, 3])
# Tensors don't change unless reassigned, when you do an operation, you need to assign it to a new tensor
```


```python
tensor + 10, torch.add(tensor, 10)
```




    (tensor([11, 12, 13]), tensor([11, 12, 13]))




```python
tensor - 10, torch.sub(tensor, 10)
```




    (tensor([-9, -8, -7]), tensor([-9, -8, -7]))




```python
tensor * 10, torch.multiply(tensor, 10), torch.mul(tensor, 10)
```




    (tensor([10, 20, 30]), tensor([10, 20, 30]), tensor([10, 20, 30]))




```python
tensor / 10, torch.divide(tensor, 10), torch.div(tensor, 10)
```




    (tensor([0.1000, 0.2000, 0.3000]),
     tensor([0.1000, 0.2000, 0.3000]),
     tensor([0.1000, 0.2000, 0.3000]))




```python
# Element-wise multiplication (each element multiplies its equivalent, index 0->0, 1->1, 2->2)
tensor * tensor, torch.mul(tensor, tensor)
```




    (tensor([1, 4, 9]), tensor([1, 4, 9]))



### 5.2 matrix multiplication (is all you need)


```python
import torch

tensor = torch.tensor([1, 2, 3])
tensor.shape
```




    torch.Size([3])




```python
tensor * tensor, torch.mul(tensor, tensor)
```




    (tensor([1, 4, 9]), tensor([1, 4, 9]))




```python
tensor @ tensor, torch.matmul(tensor, tensor)
# torch.mm(tensor, tensor) this will error, as the tensors are not matrices
```




    (tensor(14), tensor(14))



### 5.3 common error, shape mismatch


```python
# Shapes need to be in the right way  
tensor_A = torch.tensor([[1, 2],
                         [3, 4],
                         [5, 6]], dtype=torch.float32)

tensor_B = torch.tensor([[7, 10],
                         [8, 11],  #
                         [9, 12]], dtype=torch.float32)

torch.matmul(tensor_A, tensor_B)  # (this will error)
```


    ---------------------------------------------------------------------------

    RuntimeError                              Traceback (most recent call last)

    Cell In[32], line 10
          2 tensor_A = torch.tensor([[1, 2],
          3                          [3, 4],
          4                          [5, 6]], dtype=torch.float32)
          6 tensor_B = torch.tensor([[7, 10],
          7                          [8, 11],  #
          8                          [9, 12]], dtype=torch.float32)
    ---> 10 torch.matmul(tensor_A, tensor_B)


    RuntimeError: mat1 and mat2 shapes cannot be multiplied (3x2 and 3x2)



```python
print(tensor_A)
print(tensor_B)
```


```python
print(tensor_A)
print(tensor_B.T)
```


```python
# The operation works when tensor_B is transposed
print(f"Original shapes: tensor_A = {tensor_A.shape}, tensor_B = {tensor_B.shape}\n")
print(f"New shapes: tensor_A = {tensor_A.shape} (same as above), tensor_B.T = {tensor_B.T.shape}\n")
print(f"Multiplying: {tensor_A.shape} * {tensor_B.T.shape} <- inner dimensions match\n")
print("Output:\n")
output = torch.matmul(tensor_A, tensor_B.T)
print(output)
print(f"\nOutput shape: {output.shape}")
```


```python
tensor_A @ tensor_B.T, torch.matmul(tensor_A, tensor_B.T), torch.mm(tensor_A, tensor_B.T)
```

### 5.4 linear layer


```python
torch.manual_seed(42)
linear = torch.nn.Linear(in_features=2, out_features=6)
x = tensor_A
output = linear(x)
print(f"Input shape: {x.shape}\n")
print(f"Output:\n{output}\n\nOutput shape: {output.shape}")
```

    Input shape: torch.Size([3, 2])
    
    Output:
    tensor([[2.2368, 1.2292, 0.4714, 0.3864, 0.1309, 0.9838],
            [4.4919, 2.1970, 0.4469, 0.5285, 0.3401, 2.4777],
            [6.7469, 3.1648, 0.4224, 0.6705, 0.5493, 3.9716]],
           grad_fn=<AddmmBackward0>)
    
    Output shape: torch.Size([3, 6])


## 6 aggregation: sum, mean, max, min, etc


```python
x = torch.arange(0, 100, 10)
x, x.dtype
```




    (tensor([ 0, 10, 20, 30, 40, 50, 60, 70, 80, 90]), torch.int64)




```python
print(f"Minimum: {x.min()}")
print(f"Maximum: {x.max()}")
# print(f"Mean: {x.mean()}") # this will error
print(f"Mean: {x.type(torch.float32).mean()}")  # won't work without float datatype
print(f"Sum: {x.sum()}")
```

    Minimum: 0
    Maximum: 90
    Mean: 45.0
    Sum: 450



```python
torch.max(x), torch.min(x), torch.mean(x.type(torch.float32)), torch.sum(x)
```




    (tensor(90), tensor(0), tensor(45.), tensor(450))




```python
# Create a tensor
tensor = torch.arange(10, 100, 10)
print(f"Tensor: {tensor}")

# Returns index of max and min values
print(f"Index where max value occurs: {tensor.argmax()}")
print(f"Index where min value occurs: {tensor.argmin()}")
```

    Tensor: tensor([10, 20, 30, 40, 50, 60, 70, 80, 90])
    Index where max value occurs: 8
    Index where min value occurs: 0



```python
torch.argmax(tensor), torch.argmin(tensor)
```




    (tensor(8), tensor(0))



## 7 change data type


```python
tensor.type(torch.float16)
```




    tensor([10., 20., 30., 40., 50., 60., 70., 80., 90.], dtype=torch.float16)




```python
tensor.type(torch.int8)
```




    tensor([10, 20, 30, 40, 50, 60, 70, 80, 90], dtype=torch.int8)



## 8 **reshape,stacking,squeeze,unsqueeze**

Often times you'll want to reshape or change the dimensions of your tensors without actually changing the values inside them.

To do so, some popular methods are:

| Method | One-line description |
| ----- | ----- |
| [`torch.reshape(input, shape)`](https://pytorch.org/docs/stable/generated/torch.reshape.html#torch.reshape) | Reshapes `input` to `shape` (if compatible), can also use `torch.Tensor.reshape()`. |
| [`Tensor.view(shape)`](https://pytorch.org/docs/stable/generated/torch.Tensor.view.html) | Returns a view of the original tensor in a different `shape` but shares the same data as the original tensor. |
| [`torch.stack(tensors, dim=0)`](https://pytorch.org/docs/1.9.1/generated/torch.stack.html) | Concatenates a sequence of `tensors` along a new dimension (`dim`), all `tensors` must be same size. |
| [`torch.squeeze(input)`](https://pytorch.org/docs/stable/generated/torch.squeeze.html) | Squeezes `input` to remove all the dimenions with value `1`. |
| [`torch.unsqueeze(input, dim)`](https://pytorch.org/docs/1.9.1/generated/torch.unsqueeze.html) | Returns `input` with a dimension value of `1` added at `dim`. | 
| [`torch.permute(input, dims)`](https://pytorch.org/docs/stable/generated/torch.permute.html) | Returns a *view* of the original `input` with its dimensions permuted (rearranged) to `dims`. | 


```python
# Create a tensor
import torch

x = torch.arange(1., 8.)
x, x.shape
```




    (tensor([1., 2., 3., 4., 5., 6., 7.]), torch.Size([7]))




```python
x_reshaped = torch.reshape(x, (1, 7))
x_reshaped, x_reshaped.shape
```




    (tensor([[1., 2., 3., 4., 5., 6., 7.]]), torch.Size([1, 7]))



#TODO: 阅读 https://stackoverflow.com/a/54507446/7900723


```python
x_view = x.view(1, 7)
x_view, x_view.shape
```




    (tensor([[1., 2., 3., 4., 5., 6., 7.]]), torch.Size([1, 7]))




```python
# change x_view, x_reshaped will also change
x_view[:, 0] = 7
x_view, x
```




    (tensor([[7., 2., 3., 4., 5., 6., 7.]]), tensor([7., 2., 3., 4., 5., 6., 7.]))



If we wanted to stack our new tensor on top of itself five times, we could do so with `torch.stack()`.


```python
x_stacked = torch.stack([x, x, x, x, x], dim=0)
x_stacked, x_stacked.shape
```




    (tensor([[7., 2., 3., 4., 5., 6., 7.],
             [7., 2., 3., 4., 5., 6., 7.],
             [7., 2., 3., 4., 5., 6., 7.],
             [7., 2., 3., 4., 5., 6., 7.],
             [7., 2., 3., 4., 5., 6., 7.]]),
     torch.Size([5, 7]))




```python
x_stacked = torch.stack([x, x, x, x, x], dim=1)
x_stacked, x_stacked.shape
```




    (tensor([[7., 7., 7., 7., 7.],
             [2., 2., 2., 2., 2.],
             [3., 3., 3., 3., 3.],
             [4., 4., 4., 4., 4.],
             [5., 5., 5., 5., 5.],
             [6., 6., 6., 6., 6.],
             [7., 7., 7., 7., 7.]]),
     torch.Size([7, 5]))




```python
print(f"Previous tensor: {x_reshaped}")
print(f"Previous shape: {x_reshaped.shape}")

# Remove extra dimension from x_reshaped
x_squeezed = x_reshaped.squeeze()
print(f"\nNew tensor: {x_squeezed}")
print(f"New shape: {x_squeezed.shape}")
```

    Previous tensor: tensor([[7., 2., 3., 4., 5., 6., 7.]])
    Previous shape: torch.Size([1, 7])
    
    New tensor: tensor([7., 2., 3., 4., 5., 6., 7.])
    New shape: torch.Size([7])



```python
print(f"Previous tensor: {x_squeezed}")
print(f"Previous shape: {x_squeezed.shape}")

## Add an extra dimension with unsqueeze
x_unsqueezed = x_squeezed.unsqueeze(dim=0)
print(f"\nNew tensor: {x_unsqueezed}")
print(f"New shape: {x_unsqueezed.shape}")
```

    Previous tensor: tensor([7., 2., 3., 4., 5., 6., 7.])
    Previous shape: torch.Size([7])
    
    New tensor: tensor([[7., 2., 3., 4., 5., 6., 7.]])
    New shape: torch.Size([1, 7])


You can also rearrange the order of axes values with `torch.permute(input, dims)`, where the `input` gets turned into a *view* with new `dims`.
> **Note**: Because permuting returns a *view* (shares the same data as the original), the values in the permuted tensor will be the same as the original tensor and if you change the values in the view, it will change the values of the original.


```python
# Create tensor with specific shape
x_original = torch.rand(size=(224, 224, 3))

# Permute the original tensor to rearrange the axis order
x_permuted = x_original.permute(2, 0, 1)  # shifts axis 0->1, 1->2, 2->0

print(f"Previous shape: {x_original.shape}")
print(f"New shape: {x_permuted.shape}")
```

    Previous shape: torch.Size([224, 224, 3])
    New shape: torch.Size([3, 224, 224])


## 9 indexing: select data from tensor


```python
# Create a tensor 
import torch

x = torch.arange(1, 10).reshape(1, 3, 3)
x, x.shape
```




    (tensor([[[1, 2, 3],
              [4, 5, 6],
              [7, 8, 9]]]),
     torch.Size([1, 3, 3]))




```python
# Let's index bracket by bracket
print(f"First square bracket:\n{x[0]}")
print(f"Second square bracket: {x[0][0]}")
print(f"Third square bracket: {x[0][0][0]}")
```

    First square bracket:
    tensor([[1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]])
    Second square bracket: tensor([1, 2, 3])
    Third square bracket: 1



```python
x[0], x[0, 0], x[0, 0, 0]
```




    (tensor([[1, 2, 3],
             [4, 5, 6],
             [7, 8, 9]]),
     tensor([1, 2, 3]),
     tensor(1))



You can also use `:` to specify "all values in this dimension" and then use a comma (`,`) to add another dimension.


```python
# Get all values of 0th dimension and the 0 index of 1st dimension
x[:, 0]
```




    tensor([[1, 2, 3]])




```python
# Get all values of 0th & 1st dimensions but only index 1 of 2nd dimension
x[:, :, 1]
```




    tensor([[2, 5, 8]])




```python
# Get all values of the 0 dimension but only the 1 index value of the 1st and 2nd dimension
x[:, 1, 1]
```




    tensor([5])




```python
# Get index 0 of 0th and 1st dimension and all values of 2nd dimension 
x[0, 0, :]  # same as x[0][0]
```




    tensor([1, 2, 3])



## 10 PyTorch tensors & NumPy

Since NumPy is a popular Python numerical computing library, PyTorch has functionality to interact with it nicely.

The two main methods you'll want to use for NumPy to PyTorch (and back again) are:
* [`torch.from_numpy(ndarray)`](https://pytorch.org/docs/stable/generated/torch.from_numpy.html) - NumPy array -> PyTorch tensor.
* [`torch.Tensor.numpy()`](https://pytorch.org/docs/stable/generated/torch.Tensor.numpy.html) - PyTorch tensor -> NumPy array.


```python
# NumPy array to tensor
import torch
import numpy as np
array = np.arange(1.0, 8.0)
tensor = torch.from_numpy(array)
array, tensor
```




    (array([1., 2., 3., 4., 5., 6., 7.]),
     tensor([1., 2., 3., 4., 5., 6., 7.], dtype=torch.float64))



By default, NumPy arrays are created with the datatype `float64` and if you convert it to a PyTorch tensor, it'll keep the same datatype (as above).

However, many PyTorch calculations default to using `float32`.

So if you want to convert your NumPy array (float64) -> PyTorch tensor (float64) -> PyTorch tensor (float32), you can use `tensor = torch.from_numpy(array).type(torch.float32)`.


```python
tensor= torch.from_numpy(array).type(torch.float32)
```


```python
# Tensor to NumPy array
tensor = torch.ones(7) # create a tensor of ones with dtype=float32
numpy_tensor = tensor.numpy() # will be dtype=float32 unless changed
tensor, numpy_tensor
```




    (tensor([1., 1., 1., 1., 1., 1., 1.]),
     array([1., 1., 1., 1., 1., 1., 1.], dtype=float32))



## 11 Reproducibility: trying to take the random out of random

#TODO: [The PyTorch reproducibility documentation](https://pytorch.org/docs/stable/notes/randomness.html)

#TODO: [The Wikipedia random seed page](https://en.wikipedia.org/wiki/Random_seed)


```python
import torch

# Create two random tensors
random_tensor_A = torch.rand(3, 4)
random_tensor_B = torch.rand(3, 4)

print(f"Tensor A:\n{random_tensor_A}\n")
print(f"Tensor B:\n{random_tensor_B}\n")
print(f"Does Tensor A equal Tensor B? (anywhere)")
random_tensor_A == random_tensor_B
```

    Tensor A:
    tensor([[0.8016, 0.3649, 0.6286, 0.9663],
            [0.7687, 0.4566, 0.5745, 0.9200],
            [0.3230, 0.8613, 0.0919, 0.3102]])
    
    Tensor B:
    tensor([[0.9536, 0.6002, 0.0351, 0.6826],
            [0.3743, 0.5220, 0.1336, 0.9666],
            [0.9754, 0.8474, 0.8988, 0.1105]])
    
    Does Tensor A equal Tensor B? (anywhere)





    tensor([[False, False, False, False],
            [False, False, False, False],
            [False, False, False, False]])




```python
import torch
import random

# # Set the random seed
RANDOM_SEED=42 # try changing this to different values and see what happens to the numbers below
torch.manual_seed(seed=RANDOM_SEED) 
random_tensor_C = torch.rand(3, 4)

# Have to reset the seed every time a new rand() is called 
# Without this, tensor_D would be different to tensor_C 
torch.random.manual_seed(seed=RANDOM_SEED) # try commenting this line out and seeing what happens
random_tensor_D = torch.rand(3, 4)

print(f"Tensor C:\n{random_tensor_C}\n")
print(f"Tensor D:\n{random_tensor_D}\n")
print(f"Does Tensor C equal Tensor D? (anywhere)")
random_tensor_C == random_tensor_D
```

    Tensor C:
    tensor([[0.8823, 0.9150, 0.3829, 0.9593],
            [0.3904, 0.6009, 0.2566, 0.7936],
            [0.9408, 0.1332, 0.9346, 0.5936]])
    
    Tensor D:
    tensor([[0.8823, 0.9150, 0.3829, 0.9593],
            [0.3904, 0.6009, 0.2566, 0.7936],
            [0.9408, 0.1332, 0.9346, 0.5936]])
    
    Does Tensor C equal Tensor D? (anywhere)





    tensor([[True, True, True, True],
            [True, True, True, True],
            [True, True, True, True]])




```python
import torch
import random

# # Set the random seed
RANDOM_SEED=42 # try changing this to different values and see what happens to the numbers below
torch.manual_seed(seed=RANDOM_SEED) 
random_tensor_C = torch.rand(3, 4)

# Have to reset the seed every time a new rand() is called 
# Without this, tensor_D would be different to tensor_C 
# torch.random.manual_seed(seed=RANDOM_SEED) # try commenting this line out and seeing what happens
random_tensor_D = torch.rand(3, 4)

print(f"Tensor C:\n{random_tensor_C}\n")
print(f"Tensor D:\n{random_tensor_D}\n")
print(f"Does Tensor C equal Tensor D? (anywhere)")
random_tensor_C == random_tensor_D
```

    Tensor C:
    tensor([[0.8823, 0.9150, 0.3829, 0.9593],
            [0.3904, 0.6009, 0.2566, 0.7936],
            [0.9408, 0.1332, 0.9346, 0.5936]])
    
    Tensor D:
    tensor([[0.8694, 0.5677, 0.7411, 0.4294],
            [0.8854, 0.5739, 0.2666, 0.6274],
            [0.2696, 0.4414, 0.2969, 0.8317]])
    
    Does Tensor C equal Tensor D? (anywhere)





    tensor([[False, False, False, False],
            [False, False, False, False],
            [False, False, False, False]])



## 12 use gpu


```python
if torch.cuda.is_available():
    device = "cuda" # Use NVIDIA GPU (if available)
    print(torch.cuda.device_count())
elif torch.backends.mps.is_available():
    device = "mps" # Use Apple Silicon GPU (if available)
    print(torch.mps.device_count())
else:
    device = "cpu" # Default to CPU if no GPU is available
    print(torch.cpu.device_count())
device
```

    1





    'mps'




```python
# Create tensor (default on CPU)
tensor = torch.tensor([1, 2, 3])

# Tensor not on GPU
print(tensor, tensor.device)

# Move tensor to GPU (if available)
tensor_on_gpu = tensor.to(device)
tensor_on_gpu
```

    tensor([1, 2, 3]) cpu





    tensor([1, 2, 3], device='mps:0')




```python
# If tensor is on GPU, can't transform it to NumPy (this will error)
tensor_on_gpu.numpy()
```


    ---------------------------------------------------------------------------

    TypeError                                 Traceback (most recent call last)

    Cell In[65], line 2
          1 # If tensor is on GPU, can't transform it to NumPy (this will error)
    ----> 2 tensor_on_gpu.numpy()


    TypeError: can't convert mps:0 device type tensor to numpy. Use Tensor.cpu() to copy the tensor to host memory first.



```python
# Instead, copy the tensor back to cpu
tensor_back_on_cpu = tensor_on_gpu.cpu().numpy()
tensor_back_on_cpu
```




    array([1, 2, 3])




```python
tensor_on_gpu
```




    tensor([1, 2, 3], device='mps:0')


