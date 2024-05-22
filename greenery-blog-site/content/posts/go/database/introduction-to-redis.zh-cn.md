---
title: "Introduction to Redis"
date: 2024-05-19T22:11:16+08:00
draft: false
toc: false
images:
tags:
  - redis
  - go-redis
categories:
    - go
    - go-basics
    - go-basics-database
---

# Redis
> code: https://github.com/Greenery-S/go-database/tree/master/redis

## 1 简介

- Redis是一个基于内存的数据存储系统。
- 基于内存，所以快，是Mysql的10到100倍。
- 为防止数据丢失，数据会周期性地持久化到磁盘。
- Redis跟业务程序是分开部署的，所以Redis可以充当分布式缓存。
- 支持丰富的数据类型：字符串（String）、哈希（Hash）、列表（List）、集合（Set）和有序集合（Sorted Set）。
- 支持发布/订阅模式，发布者将消息发送到指定的频道，订阅者可以接收和处理这些消息。这种模式常应用于实时通信、事件驱动系统和消息队列等场景。
- Redis事务太鸡肋，不建议使用。

## 2 发布/订阅模式

1. Subscriber启动之前，Channel里的消息接收不到。
2. 广播效果.

{{< image src="/images/introduction-to-redis-pubsub.png" alt="pubsub" position="center" style="border-radius: 20px; width: 100%;" >}}

## 3 分布式锁

1. `SetNX(ctx context.Context, key string, value interface{}, expiration time.Duration) *BoolCmd`
2. SetNX如果key不存在则返回true，写入key，并设置过期时间

{{< image src="/images/introduction-to-redis-distributed-key.png" alt="distributed-key" position="center" style="border-radius: 20px; width: 100%;" >}}

秒杀iphone代码示例：

```go
func TryLock(rc *redis.Client, key string, expire time.Duration) bool {
	cmd := rc.SetNX(context.Background(), key, "anything is ok", expire)
	if err := cmd.Err(); err == nil {
		return cmd.Val()
	} else {
		return false
	}
}

func ReleaseLock(rc *redis.Client, key string) {
	rc.Del(context.Background(), key)
}

func LockRace2(client *redis.Client, storage int) {
	keyLock := "lock"
	keyStorage := "store"
	client.Set(context.Background(), keyStorage, storage, 0)
	defer ReleaseLock(client, keyLock)
	defer client.Del(context.Background(), keyStorage)

	const P = 1000
	wg := sync.WaitGroup{}
	wg.Add(P)
	start := time.Now()
	for i := 0; i < P; i++ {
		go func(i int) {
			defer wg.Done()
			time.Sleep(time.Duration(rand.Intn(100)) * time.Millisecond)
			if TryLock(client, keyLock, 0) {
				if v := client.IncrBy(context.Background(), keyStorage, -1).Val(); v >= 0 {
					fmt.Printf("%d gets the No.%d iPhone! Use %v!\n", i, v+1, time.Now().Sub(start))
				}
				ReleaseLock(client, keyLock)
			}
		}(i)
	}
	wg.Wait()
}
```

## 4 内存淘汰机制

1. LRU（Least Recently Used），基于链表结构，链表中的元素按照操作顺序从前往后排列，最新操作的键会被移动到表头，当需要内存淘汰时，只需要删除链表尾部的元素即可
2. LFU（Least Frequently Used），其基本假设是如果数据过去被访问多次，那么将来被访问的频率也更高，所以淘汰那些过去使用频率最低的key。Redis使用了一个复杂但高效的方法近似地实现了LFU
3. LFU比LRU更合理一些，但实现起来更复杂

{{< image src="/images/introduction-to-redis-memory.png" alt="memory" position="center" style="border-radius: 20px; width: 100%;" >}}

## 5 常见应用场景

- 总体原则：Redis比Mysql快一个数量级，可靠性不如Mysql，所以对于那些需要高频读写、生命周期短、对用户不是特别重要的数据适合存到Redis里
- 计数器。`Incr(ctx context.Context, key string)`对应的key计数加1，比如视频播放量，秒杀场景商品库存。`INCRBY`加任意值，可以为负数
- 缓存。对于经常访问的MySQL数据可以放到Redis里，key对应id，**value是Json字符串。减轻mysql压力，提高接口响应速度**
- 会话缓存。SessionID用于标记用户登录成功，登录和后续操作可能命中不同的服务器，所以SessionID需要保存在分布式缓存中。搜索/推荐结果列表存入缓存，翻页时从缓存读取
- 分布式锁。在分布式系统中，定时任务只需要由一台服务器去执行，谁抢到锁谁执行，在下一个周期到来之前释放锁
- 发布/订阅功能。少量的事件通知可以用Redis实现，大量的消息传递更适合用kafka