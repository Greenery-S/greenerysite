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
  - group encryption
categories:
    - go
    - go-basics
    - go-basics-encryption
---

# File Encryption
> code: https://github.com/Greenery-S/go-encryption/tree/master/enc_file

## 1 Symmetric Encryption
{{< image src="/images/file-encryption-symmetric.png" alt="symmetric-encryption" position="center" style="border-radius: 0px; width: 50%;" >}}
- Every step of the encryption process is **reversible**
- The same set of keys is used for **encryption and decryption**
- XOR is the simplest symmetric encryption algorithm
  {{< image src="/images/file-encryption-xor.png" alt="symmetric-encryption" position="center" style="border-radius: 0px; width: 80%;" >}}

Typical symmetric encryption algorithms: DES (Data Encryption Standard), AES (Advanced Encryption Standard)

## 2 Group Encryption

- Group encryption: The original data (plaintext) is grouped, each group is 64 bits, and when the last group is less than 64 bits, it is filled according to certain rules. The DES algorithm is applied separately to each group
- CBC (Cipher Block Chaining) ciphertext group link mode, the current plaintext group is XORed with the previous ciphertext group, and then encrypted

{{< image src="/images/file-encryption-cbc.png" alt="symmetric-encryption" position="center" style="border-radius: 0px; width: 100%;" >}}

See the code link for the code.

### Digital Padding
PKCS#5 and PKCS#7 are two common data padding standards, both of which are part of the PKCS (Public-Key Cryptography Standards) series of standards.
- PKCS#5: Mainly used to describe the padding method of block ciphers in cryptography. In practical applications, when the size of the data block is not the fixed length required by the password algorithm, padding is required. The PKCS#5 padding method is to pad a byte sequence at the end of the data block, **each byte's value is equal to the number of missing bytes**. For example, if the data block length is 6, and the **password algorithm requires a length of 8**, two bytes need to be padded at the end of the data block, each byte's value is 2.
- PKCS#7: It is an extension of PKCS#5, it supports data blocks of any length, not just 8 bytes. The **padding method of PKCS#7 is the same as PKCS#5**, both are to pad a byte sequence at the end of the data block, each byte's value is equal to the number of missing bytes.

```go
// pkcs7padding and pkcs5padding have the same padding method, the value of the padding byte is equal to the number of padding bytes.
// For example, if you need to pad 4 bytes, the padding value is "4 4 4 4".
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
  //Note: When srcLen is an integer multiple of blockSize, padLen is equal to blockSize rather than 0
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



## 3 Asymmetric Encryption

{{< image src="/images/file-encryption-asymmetric.png" alt="asymmetric-encryption" position="center" style="border-radius: 0px; width: 50%;" >}}

- Encrypt with the public key, decrypt with the private key
- The public key and the private key are different
  - The public key can be published to everyone
  - **The private key is only saved by yourself**
- **The public key is derived from the private key**
- Compared to symmetric encryption, **the operation speed is very slow**
- Blockchain technology is the application of asymmetric encryption technology
  {{< image src="/images/file-encryption-blockchain.png" alt="asymmetric-encryption" position="center" style="border-radius: 0px; width: 80%;" >}}

Typical asymmetric encryption algorithms: RSA (Ron Rivest, Adi Shamir, Leonard Adleman), ECC (Elliptic Curve Cryptography) elliptic curve encryption algorithm

In the next lecture "Digital Signature", we will talk about the go code of asymmetric encryption.