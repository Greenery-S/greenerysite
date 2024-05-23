---
title: "File Encryption"
date: 2024-05-22T17:42:47+08:00
draft: false
toc: false
images:
tags:
  - encryption
  - symmetric encryption
  - asymmetric encryption
  - gruop encryption
categories:
    - go
    - go-basics
    - go-basics-encryption
---

# 文件加密
> code: https://github.com/Greenery-S/go-encryption/tree/master/enc_file

## 1 对称加密
{{< image src="/images/file-encryption-symmetric.png" alt="symmetric-encryption" position="center" style="border-radius: 0px; width: 50%;" >}}
- 加密过程的每一步都是**可逆的**
- 加密和解密用的是**同一组密钥**
- 异或是最简单的对称加密算法
{{< image src="/images/file-encryption-xor.png" alt="symmetric-encryption" position="center" style="border-radius: 0px; width: 80%;" >}}

典型对称加密算法：DES（Data Encryption Standard）AES(Advanced Encryption Standard)

## 2 分组加密

- 分组加密：对原始数据（明文）进行分组，每组64位，最后一组不足64位时按一定规则填充。每一组上单独施加DES算法
- CBC（Cipher Block Chaining）密文分组链接模式，将当前明文分组与前一个密文分组进行异或运算，然后再进行加密

{{< image src="/images/file-encryption-cbc.png" alt="symmetric-encryption" position="center" style="border-radius: 0px; width: 100%;" >}}

代码见code链接.

### 数字填充
PKCS#5 和 PKCS#7 是两种常见的数据填充标准，它们都属于 PKCS (Public-Key Cryptography Standards) 系列标准的一部分。  
- PKCS#5：主要用于描述密码学中的分组密码的填充方式。在实际应用中，当数据块的大小不是密码算法所需要的固定长度时，就需要进行填充。PKCS#5 填充方式是在数据块末尾填充一个字节序列，**每个字节的值等于缺少的字节的数量**。例如，如果数据块长度为 6，而**密码算法需要的长度为 8**，则需要在数据块末尾填充两个字节，每个字节的值为 2。  
- PKCS#7：是 PKCS#5 的扩展，它支持任何长度的数据块，而不仅仅是 8 字节。PKCS#7 的**填充方式与 PKCS#5 相同**，都是在数据块末尾填充一个字节序列，每个字节的值等于缺少的字节的数量。

```go
// pkcs7padding和pkcs5padding的填充方式相同，填充字节的值都等于填充字节的个数。
// 例如需要填充4个字节，则填充的值为"4 4 4 4"。
var (
  // only difference is the block size, PKCS5 is 8 bytes, PKCS7 can be any bytes
  PKCS5          = &pkcs5{}
  PKCS7          = &pkcs5{}
  ErrPaddingSize = errors.New("padding size error")
)

// pkcs5Padding is a pkcs5 padding struct.
type pkcs5 struct{}

// Padding implements the Padding interface Padding method.
func (p *pkcs5) Padding(src []byte, blockSize int) []byte {
  srcLen := len(src)
  //注意： 当srcLen是blockSize的整倍数时，padLen等于blockSize而非0
  padLen := blockSize - (srcLen % blockSize)
  padText := bytes.Repeat([]byte{byte(padLen)}, padLen)
  return append(src, padText...)
}

// Unpadding implements the Padding interface Unpadding method.
func (p *pkcs5) Unpadding(src []byte, blockSize int) ([]byte, error) {
  srcLen := len(src)
  paddingLen := int(src[srcLen-1])
  if paddingLen >= srcLen || paddingLen > blockSize {
    return nil, ErrPaddingSize
  }
  return src[:srcLen-paddingLen], nil
}

func main() {
  o := []byte("hello world!")
  p := PKCS5.Padding(o, 8)
  u, _ := PKCS5.Unpadding(p, 8)
  fmt.Println(p)
  // [104 101 108 108 111 32 119 111 114 108 100 33 4 4 4 4]
  fmt.Println(u)
  // [104 101 108 108 111 32 119 111 114 108 100 33]
}
```



## 3 非对称加密

{{< image src="/images/file-encryption-asymmetric.png" alt="asymmetric-encryption" position="center" style="border-radius: 0px; width: 50%;" >}}

- 使用公钥加密，使用私钥解密 
- 公钥和私钥不同 
  - 公钥可以公布给所有人 
  - **私钥只有自己保存**
- **公钥是从私钥中派生出来的** 
- 相比于对称加密，**运算速度非常慢**
- 区块链技术就是运用了非对称加密技术
{{< image src="/images/file-encryption-blockchain.png" alt="asymmetric-encryption" position="center" style="border-radius: 0px; width: 80%;" >}}

典型韭对称加密算法：RSA（Ron Rivest, Adi Shamir, Leonard Adleman），ECC（Elliptic Curve Cryptography）椭圆曲线加密算法

在下一讲"数字签名"中，我们将会讲到非对称加密的go代码.