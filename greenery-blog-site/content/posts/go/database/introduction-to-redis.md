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
> Code: https://github.com/Greenery-S/go-database/tree/master/redis

## 1 Introduction

- Redis is an in-memory data storage system.
- Since it is based on memory, it is fast, being 10 to 100 times faster than MySQL.
- To prevent data loss, data is periodically persisted to disk.
- Redis is deployed separately from the business application, so it can serve as a distributed cache.
- It supports a rich variety of data types: strings, hashes, lists, sets, and sorted sets.
- It supports the publish/subscribe model, where publishers send messages to specified channels, and subscribers can receive and process these messages. This model is commonly used in real-time communication, event-driven systems, and message queues.
- Redis transactions are not recommended as they are considered too limited.

## 2 Publish/Subscribe Model

1. Messages in the channel are not received before the subscriber starts.
2. Broadcast effect.

{{< image src="/images/introduction-to-redis-pubsub.png" alt="pubsub" position="center" style="border-radius: 20px; width: 100%;" >}}

## 3 Distributed Lock

1. `SetNX(ctx context.Context, key string, value interface{}, expiration time.Duration) *BoolCmd`
2. SetNX returns true and writes the key with an expiration time if the key does not exist.

{{< image src="/images/introduction-to-redis-distributed-key.png" alt="distributed-key" position="center" style="border-radius: 20px; width: 100%;" >}}

Example code for iPhone flash sale:

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

## 4 Memory Eviction Mechanism

1. LRU (Least Recently Used): Based on a linked list structure, elements in the list are arranged in the order of operations. The most recently operated keys are moved to the head of the list. When memory eviction is needed, the elements at the tail of the list are deleted.
2. LFU (Least Frequently Used): The basic assumption is that data accessed frequently in the past will also be accessed more frequently in the future, so the keys with the lowest usage frequency in the past are evicted. Redis uses a complex but efficient method to approximate LFU.
3. LFU is more reasonable than LRU but more complex to implement.

{{< image src="/images/introduction-to-redis-memory.png" alt="memory" position="center" style="border-radius: 20px; width: 100%;" >}}

## 5 Common Application Scenarios

- **General Principle:** Redis is an order of magnitude faster than MySQL but less reliable. It is suitable for storing data that requires high-frequency reads and writes, has a short lifecycle, and is not critically important to users.
- **Counter:** `Incr(ctx context.Context, key string)` increments the counter for the corresponding key, such as video views or inventory in a flash sale scenario. `INCRBY` can increment by any value, including negative numbers.
- **Cache:** Frequently accessed MySQL data can be stored in Redis, with keys corresponding to IDs and values as JSON strings. This reduces MySQL load and improves API response speed.
- **Session Cache:** Session IDs are used to mark successful user logins. Logins and subsequent operations may hit different servers, so session IDs need to be stored in distributed cache. Search/recommendation result lists are stored in cache and read from cache when paging.
- **Distributed Lock:** In a distributed system, scheduled tasks only need to be executed by one server. Whoever acquires the lock executes the task and releases the lock before the next cycle.
- **Publish/Subscribe Function:** Redis can be used for small-scale event notifications, while Kafka is more suitable for large-scale message passing.