---
title: "Lo All Examples"
date: 2024-08-15T17:46:09+08:00
draft: false
toc: true
images:
tags:
  - go
  - lo
categories:
    - go
    - go-lo
---

# Lo Learn - all examples
> https://github.com/samber/lo
---
## Demo for slices: demos for filter
> Iterates over a collection and returns an array of all the elements the predicate function returns true for.

```
Running example:
Result:
Even numbers:[2 4 6 8 10]
Odd numbers:[1 3 5 7 9]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/filter.go:34
```

---
## Demo for slices: demos for map
> Manipulates a slice of one type and transforms it into a slice of another type

```
Running example:
Result:
[2 4 6 8]
[1x2=2 2x2=4 3x2=6 4x2=8]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/map.go:31
```

---
## Demo for slices: demos for filter_map
> Returns a slice which obtained after both filtering and mapping using the given callback function.
The callback function should return two values: the result of the mapping operation and whether the result element should be included or not.

```
Running example:
Result:
[4 8]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/filter_map.go:28
```

---
## Demo for slices: demos for flat_slice
> Manipulates a slice and transforms and flattens it to a slice of another type. The transform function can either return a slice or a nil, and in the nil case no value is added to the final slice.

```
Running example:
Result:
[11 3 3 3 110 6 6 6 1001 11 9 9 1100 14 12 c]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/flat_slice.go:32
```

---
## Demo for slices: demos for reduce
> Reduces a collection to a single value. The value is calculated by accumulating the result of running each element in the collection through an accumulator function. Each successive invocation is supplied with the return value returned by the previous call.

```
Running example:
Result:
10
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/reduce.go:27
```

---
## Demo for slices: demos for reduce_right
> Like lo.Reduce except that it iterates over elements of collection from right to left.

```
Running example:
Result:
[10086 8848 7 8 9 4 5 6 1 2 3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/reduce_right.go:31
```

---
## Demo for slices: demos for for_each
> Iterates over a collection and applies a function to each element.

```
Running example:
index: 0, value: 1
index: 1, value: 2
index: 2, value: 3
index: 3, value: 4
index: 4, value: 5
index: 5, value: 6
index: 6, value: 7
index: 7, value: 8
index: 8, value: 9
index: 9, value: 10
Result:
Sequential execution
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/for_each.go:29
```

---
## Demo for slices: demos for for_each_parallel
> Like lo.ForEach except that it runs the iteratee function in parallel.

```
Running example:
index: 9, value: 10
index: 0, value: 1
index: 4, value: 5
index: 1, value: 2
index: 5, value: 6
index: 7, value: 8
index: 8, value: 9
index: 3, value: 4
index: 2, value: 3
index: 6, value: 7
Result:
Parallel execution
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/for_each.go:51
```

---
## Demo for slices: demos for for_each_while
> Iterates over a collection and applies a function to each element. The iteratee function can return false to break the loop.

```
Running example:
index: 0, value: 1
index: 1, value: 2
index: 2, value: 3
index: 3, value: 4
index: 4, value: 5
Result:
Sequential execution
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/for_each.go:74
```

---
## Demo for slices: demos for times
> Times invokes the iteratee n times, returning an array of the results of each invocation. The iteratee is invoked with index as argument.

```
Running example:
Result:
406.918375ms
[banana bananana banananana bananananana banananananana]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/times.go:30
```

---
## Demo for slices: demos for times_parallel
> Like lo.Times except that it runs the iteratee function in parallel.

```
Running example:
Result:
101.138959ms
[banana bananana banananana bananananana banananananana]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/times.go:55
```

---
## Demo for slices: demos for uniq
> Creates a duplicate-free version of an array.

```
Running example:
Result:
[1 2 3 4 5 6 7 8 9 10]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/uniq.go:23
```

---
## Demo for slices: demos for uniq_by
> Creates a duplicate-free version of an array, using a function to determine uniqueness.

```
Running example:
Result:
[1 2]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/uniq.go:43
```

---
## Demo for slices: demos for group_by
> Groups the elements of a collection based on the given function.

```
Running example:
Result:
map[0:[3 6 9] 1:[1 4 7 10] 2:[2 5 8]]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/group_by.go:27
```

---
## Demo for slices: demos for chunk
> Creates an array of elements split into groups the length of size.

```
Running example:
Result:
[[1 2 3] [4 5 6] [7 8 9] [10]]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/chunk.go:25
```

---
## Demo for slices: demos for partition_by
> Returns an array of elements split into groups. The order of grouped values is determined by the order they occur in collection. The grouping is generated from the results of running each element of collection through iteratee.

```
Running example:
Result:
[[-2 -1] [1 3 5 7 9] [2 4 6 8 10]]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/partition_by.go:34
```

---
## Demo for slices: demos for partition_parallel
> Like lo.PartitionBy except that it runs the iteratee function in parallel.

```
Running example:
Result:
[[10 2 4 6 8] [-2 -1] [1 3 5 7 9]]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/partition_by.go:62
```

---
## Demo for slices: demos for flatten
> Returns an array a single level deep.

```
Running example:
Result:
[1 2 3 4]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/flatten.go:23
```

---
## Demo for slices: demos for interleave
> Round-robin alternating input slices and sequentially appending value at index into result.

```
Running example:
Result:
[a 1 x b 2 z c 3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/interleave.go:25
```

---
## Demo for slices: demos for shuffle
> Returns an array of shuffled values. Uses the Fisher-Yates shuffle algorithm.

```
Running example:
Result:
[10 7 9 1 2 8 6 3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/shuffle.go:21
```

---
## Demo for slices: demos for reverse
> Reverses a slice.This helper is mutable. This behavior might change in v2.0.0.

```
Running example:
Result:
[5 4 3 2 1]
[5 4 3 2 1]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/reverse.go:21
```

---
## Demo for slices: demos for fill
> Fills elements of slice with value.

```
Running example:
Result:
[[-1 -1 -1] [-1 -1 -1] [-1 -1 -1]]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/fill.go:28
```

---
## Demo for slices: demos for repeat
> Creates a slice with n values of v.

```
Running example:
Result:
[[1 2 3] [1 2 3]]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/repeat.go:21
```

---
## Demo for slices: demos for repeat_by
> Builds a slice with values returned by N calls of callback.

```
Running example:
Result:
[0 1 4]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/repeat_by.go:24
```

---
## Demo for slices: demos for key_by
> Transforms a slice or an array of structs to a map based on a pivot callback.

```
Running example:
Result:
map[001:{001 Alice 20} 002:{002 Alice 20} 003:{003 Bob 21} 004:{004 Charlie 22} 005:{005 David 23}]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/key_by.go:37
```

---
## Demo for slices: demos for associate
> Returns a map containing key-value pairs provided by transform function applied to elements of the given slice. If any of two pairs would have the same key the last one gets added to the map.

```
Running example:
Result:
map[001:Alice is 20 years old 002:Alice is 20 years old 003:Bob is 21 years old 004:Charlie is 22 years old 005:David is 23 years old]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/associate.go:32
```

---
## Demo for slices: demos for drop
> Removes n elements from the beginning of slice.

```
Running example:
Result:
[1 2 3 4 5]
[3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/drop.go:21
```

---
## Demo for slices: demos for dropRight
> Removes n elements from the end of slice.

```
Running example:
Result:
[1 2 3 4 5]
[1 2 3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/drop.go:37
```

---
## Demo for slices: demos for dropWhile
> Removes elements from slice until predicate returns false.

```
Running example:
Result:
[1 2 3 2 1]
[3 2 1]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/drop.go:55
```

---
## Demo for slices: demos for dropRightWhile
> Removes elements from slice until predicate returns false.

```
Running example:
Result:
[1 2 3 2 1]
[1 2 3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/drop.go:73
```

---
## Demo for slices: demos for dropByIndex
> Drops elements from a slice or array by the index. A negative index will drop elements from the end of the slice.

```
Running example:
Result:
[0 1 2 3 4 5]
[0 2 4]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/drop.go:89
```

---
## Demo for slices: demos for reject
> Rejects elements of slice with predicate.

```
Running example:
Result:
[1 2 3 4 5]
[1 3 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/reject.go:24
```

---
## Demo for slices: demos for rejectMap
> Rejects elements of slice with predicate and maps the result.

```
Running example:
Result:
[1 2 3 4 5]
[ood:1 ood:3 ood:5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/reject.go:42
```

---
## Demo for slices: demos for filterReject
> Mixes Filter and Reject, this method returns two slices, one for the elements of collection that predicate returns truthy for and one for the elements that predicate does not return truthy for.

```
Running example:
Result:
[2 4]
[1 3 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/reject.go:60
```

---
## Demo for slices: demos for count
> Counts the number of elements in the collection that compare equal to value.

```
Running example:
Result:
2
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/count.go:21
```

---
## Demo for slices: demos for countBy
> Counts the number of elements in the collection that predicate returns truthy for.

```
Running example:
Result:
2
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/count.go:39
```

---
## Demo for slices: demos for countValues
> Counts the number of each element in the collection.

```
Running example:
Result:
map[a:3 b:2 c:1 d:3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/count.go:55
```

---
## Demo for slices: demos for countValuesBy
> Counts the number of each element in the collection. It ss equivalent to chaining lo.Map and lo.CountValues.

```
Running example:
Result:
map[false:5 true:5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/count.go:73
```

---
## Demo for slices: demos for subset
> Returns a copy of a slice from offset up to length elements. Like slice[start:start+length], but does not panic on overflow.

```
Running example:
Result:
[3 4]
[4 5]
[]
[2]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/subset.go:24
```

---
## Demo for slices: demos for slice
> Returns a copy of a slice from start up to end elements. Like slice[start:end], but does not panic on overflow.

```
Running example:
Result:
[3 4 5]
[4 5]
[]
[1]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/subset.go:45
```

---
## Demo for slices: demos for replace
> Returns a copy of the slice with the first n non-overlapping instances of old replaced by new.

```
Running example:
Result:
[0 1 1 1 1 1 1 1 1 1]
[0 0 1 1 1 1 1 1 1 1]
[0 0 0 1 1 1 1 1 1 1]
[0 0 0 0 1 1 1 1 1 1]
[0 0 0 0 0 1 1 1 1 1]
[0 0 0 0 0 0 0 0 0 0]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/replace.go:20
```

---
## Demo for slices: demos for replaceAll
> Returns a copy of the slice with all non-overlapping instances of old replaced by new.

```
Running example:
Result:
[0 0 0 0 0 0 0 0 0 0]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/replace.go:42
```

---
## Demo for slices: demos for compact
> Returns a slice of all non-zero elements.

```
Running example:
Result:
[1 2 3 4 5]
[a b c]
[true true]
[1 2 3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/compact.go:19
```

---
## Demo for slices: demos for isSort
> Returns true if the slice is sorted.

```
Running example:
Result:
true
false
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/is_sort.go:19
```

---
## Demo for slices: demos for isSortedByKey
> Checks if a slice is sorted by iteratee.

```
Running example:
Result:
true
false
false
false
true
true
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/is_sort.go:37
```

---
## Demo for slices: demos for splice
> Splice inserts multiple elements at index i. A negative index counts back from the end of the slice. The helper is protected against overflow errors.

```
Running example:
Result:
[1 2 -1 -2 -3 3 4 5]
[1 2 3 4 -1 -2 -3 5]
[1 2 3 4 5 -1 -2 -3]
[-1 -2 -3 1 2 3 4 5]
[1 2 3 -1 -2 -3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/slices/splice.go:20
```

---
## Demo for maps: demos for keys
> Returns a slice of keys in the map.

```
Running example:
Result:
[a b c]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/keys.go:20
```

---
## Demo for maps: demos for hasKey
> Checks if a key exists in the map.

```
Running example:
Result:
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/keys.go:37
```

---
## Demo for maps: demos for values
> Returns a slice of values in the map.

```
Running example:
Result:
[1 2 3 3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/values.go:20
```

---
## Demo for maps: demos for valueOr
> Returns the value for key in the map. If the key does not exist, it returns the default value.

```
Running example:
Result:
1
8848
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/values.go:37
```

---
## Demo for maps: demos for pickBy
> Returns same map type filtered by given predicate.

```
Running example:
Result:
map[b:2 d:4 f:6 h:8 j:10]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/pick_by.go:20
```

---
## Demo for maps: demos for pickByKeys
> Returns same map type filtered by given keys.

```
Running example:
Result:
map[a:1 b:2 i:9]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/pick_by.go:39
```

---
## Demo for maps: demos for pickByValues
> Returns same map type filtered by given values.

```
Running example:
Result:
map[a:1 b:2 i:9 j:9]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/pick_by.go:56
```

---
## Demo for maps: demos for omitBy
> Creates an object composed of the properties the given function returns falsey for.

```
Running example:
Result:
map[a:1 b:2 c:3 d:4 e:5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/omit_by.go:20
```

---
## Demo for maps: demos for omitByKeys
> Creates an object composed of the properties not in the given keys.

```
Running example:
Result:
map[c:3 d:4 e:5 f:6 g:7 h:8 j:10]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/omit_by.go:37
```

---
## Demo for maps: demos for omitByValues
> Creates an object composed of the properties not in the given values.

```
Running example:
Result:
map[c:3 d:4 e:5 f:6 g:7 h:8]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/omit_by.go:54
```

---
## Demo for maps: demos for entries
> Transforms a map into array of key/value pairs.

```
Running example:
Result:
[{c 3} {a 1} {b 2}]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/entries.go:20
```

---
## Demo for maps: demos for fromEntries
> Transforms an array of key/value pairs into a map.

```
Running example:
Result:
map[a:1 b:2 c:3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/entries.go:41
```

---
## Demo for maps: demos for invert
> Creates a map composed of the inverted keys and values. If map contains duplicate values, subsequent values overwrite property assignments of previous values.

```
Running example:
Result:
map[1:a 2:d 3:c]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/invert.go:20
```

---
## Demo for maps: demos for assign
> Merges multiple maps from left to right.

```
Running example:
Result:
map[a:1 b:3 c:4 d:5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/invert.go:39
```

---
## Demo for maps: demos for mapKeys
> Manipulates a map keys and transforms it to a map of another type.

```
Running example:
Result:
map[A:1 B:2 C:3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/map.go:21
```

---
## Demo for maps: demos for mapValues
> Manipulates a map values and transforms it to a map of another type.

```
Running example:
Result:
map[1:A 2:B 3:C]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/map.go:38
```

---
## Demo for maps: demos for mapEntries
> Manipulates a map entries and transforms it to a map of another type.

```
Running example:
Result:
map[A:a B:b C:c]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/map.go:55
```

---
## Demo for maps: demos for mapToSlice
> Transforms a map into a slice based on specific iteratee.

```
Running example:
Result:
[a::1 b::2 c::3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/maps/map.go:74
```

---
## Demo for math: demos for range/rangeFrom/RangeWithSteps
> Creates an array of numbers (positive and/or negative) progressing from start up to, but not including end.

```
Running example:
Result:
[0 1 2 3 4]
[0 -1 -2 -3 -4]
[2 3 4 5 6]
[5 6]
[1 3]
[5 3]
[1 2 3 4 5]
[1 2 3 4 5]
[1 1.3 1.6 1.9000000000000001 2.2 2.5 2.8 3.0999999999999996 3.3999999999999995 3.6999999999999993 3.999999999999999 4.299999999999999 4.599999999999999 4.899999999999999]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/math/range.go:19
```

---
## Demo for math: demos for clamp
> Clamps number within the inclusive lower and upper bounds.

```
Running example:
Result:
5
0
10
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/math/clamp.go:19
```

---
## Demo for math: demos for sum
> Calculates the sum of numbers. If collection is empty 0 is returned.

```
Running example:
Result:
6
0
6.3
6.300000000000001
6
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/math/sum.go:19
```

---
## Demo for math: demos for mean
> Calculates the mean of the numbers.

```
Running example:
Result:
2
0
2.1000001
2.1
2
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/math/mean.go:19
```

---
## Demo for math: demos for meanBy
> Calculates the mean of the numbers by the given function.

```
Running example:
Result:
6.6
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/math/mean.go:39
```

---
## Demo for strings: demos for randomString
> Generates a random string of specified length

```
Running example:
Result:
ahjjb
NORVK
84220
'%.]]
OYSXraRlwv
PrLMYZm4xU9ZNLX
'N$#xEWv(4._$Q}FybWz
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/string.go:19
```

---
## Demo for strings: demos for substring
> Gets the substring of string from the start index up to, but not including, the end index.

```
Running example:
Result:
Wor
rl
lo, World!
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/string.go:41
```

---
## Demo for strings: demos for chunkString
> Splits string into an array of chunks.

```
Running example:
Result:
[1 2 3 4 5 6 7 8 9 0]
[12 34 56 78 90]
[123 456 789 0]
[1234 5678 90]
[1234567890]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/string.go:59
```

---
## Demo for strings: demos for runeLength
> Gets the number of characters in string.

```
Running example:
Result:
13
6
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/string.go:79
```

---
## Demo for strings: demos for elipse
> Truncates string to a specified length.

```
Running example:
Result:
He...
...
Hello, ...
Hello, World!
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/string.go:96
```

---
## Demo for strings: demos for PascalCase
> Converts a string to PascalCase.

```
Running example:
Result:
LoLearn
LoLearn
LoLearn
LoLearn
LoLearn
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/word.go:19
```

---
## Demo for strings: demos for CamelCase
> Converts a string to camelCase.

```
Running example:
Result:
loLearn
loLearn
loLearn
loLearn
loLearn
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/word.go:39
```

---
## Demo for strings: demos for KebabCase
> Converts a string to kebab-case.

```
Running example:
Result:
lo-learn
lo-learn
lo-learn
lo-learn
lo-learn
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/word.go:59
```

---
## Demo for strings: demos for SnakeCase
> Converts a string to snake_case.

```
Running example:
Result:
lo_learn
lo_learn
lo_learn
lo_learn
lo_learn
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/word.go:79
```

---
## Demo for strings: demos for Words
> Splits string into an array of its words.

```
Running example:
Result:
[lo Learn]
[Lo Learn]
[lo learn]
[lo learn]
[lo learn]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/word.go:99
```

---
## Demo for strings: demos for Capitalize
> Converts the first character of string to upper case and the remaining to lower case.

```
Running example:
Result:
Hello
Hello
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/strings/word.go:119
```

---
## Demo for tuples: demos for tuple and named tuple 1-9
> demos for tuple and named tuple 1-9

```
Running example:
Result:
{hello 2}
{hello 2 true}
{hello 2 true {bar}}
{hello 2 true {bar} 4.2}
{hello 2 true {bar} 4.2 plop}
{hello 2 true {bar} 4.2 plop false}
{hello 2 true {bar} 4.2 plop false 42}
{hello 2 true {bar} 4.2 plop false 42 hello world}
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/tuples/tuple.go:24
```

---
## Demo for tuples: demos for unpack
> Unpacks a tuple.

```
Running example:
Result:
hello2
hello2 true
hello2 true {bar}
hello2 true {bar} 4.2
hello2 true {bar} 4.2plop
hello2 true {bar} 4.2plopfalse
hello2 true {bar} 4.2plopfalse 42
hello2 true {bar} 4.2plopfalse 42hello world
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/tuples/tuple.go:47
```

---
## Demo for tuples: demos for zip
> Zip creates a slice of grouped elements, the first of which contains the first elements of the given arrays, the second of which contains the second elements of the given arrays, and so on.
When collections have different size, the Tuple attributes are filled with zero value.

```
Running example:
Result:
[{hello 2} {world 3}]
[{hello 2} {world 3} { 4} { 5}]
[{hello 2}]
[{hello 2 true}]
[{hello 2 true {bar}}]
[{hello 2 true {bar} 4.2}]
[{hello 2 true {bar} 4.2 plop}]
[{hello 2 true {bar} 4.2 plop false}]
[{hello 2 true {bar} 4.2 plop false 42}]
[{hello 2 true {bar} 4.2 plop false 42 hello world}]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/tuples/zip.go:20
```

---
## Demo for tuples: demos for zipBy
> ZipBy creates a slice of grouped elements, the first of which contains the result of applying the given function to the first elements of the given arrays, the second of which contains the result of applying the given function to the second elements of the given arrays, and so on.
When collections have different size, the Tuple attributes are filled with zero value.

```
Running example:
Result:
[hello::2 world::3 !::0]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/tuples/zip.go:46
```

---
## Demo for tuples: demos for unzip
> Unzip converts a slice of grouped elements into a slice of arrays.

```
Running example:
Result:
[hello world ! plop plop] [2 3 4 5 6]
[hello] [2] [true]
[hello] [2] [true] [{bar}]
[hello] [2] [true] [{bar}] [4.2]
[hello] [2] [true] [{bar}] [4.2] [plop]
[hello] [2] [true] [{bar}] [4.2] [plop] [false]
[hello] [2] [true] [{bar}] [4.2] [plop] [false] [42]
[hello] [2] [true] [{bar}] [4.2] [plop] [false] [42] [hello world]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/tuples/zip.go:74
```

---
## Demo for tuples: demos for unzipBy
> UnzipBy converts a slice of grouped elements into a slice of arrays by applying the given function.

```
Running example:
Result:
[Alice Bob Charlie]
[1 2 3]
[20 30 40]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/tuples/zip.go:110
```

---
## Demo for time and duration: demos for duration
> Returns the time taken to execute a function.

```
Running example:
Result:
11.018666ms
11.019458ms
1 10.992834ms
1 2 10.613417ms
1 2 3 11.013292ms
1 2 3 4 11.019416ms
1 2 3 4 5 10.264833ms
1 2 3 4 5 6 11.017542ms
1 2 3 4 5 6 7 11.017167ms
1 2 3 4 5 6 7 8 11.019291ms
1 2 3 4 5 6 7 8 9 11.017167ms
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/duration/duration.go:36
```

---
## Demo for channels: demos for channel dispatcher
> Distributes messages from input channels into N child channels. Close events are propagated to children.
Underlying channels can have a fixed buffer capacity or be unbuffered when cap is 0.

Many distributions strategies are available:
- lo.DispatchingStrategyRoundRobin: Distributes messages in a rotating sequential manner.
- lo.DispatchingStrategyRandom: Distributes messages in a random manner.
- lo.DispatchingStrategyWeightedRandom: Distributes messages in a weighted manner.
- lo.DispatchingStrategyFirst: Distributes messages in the first non-full channel.
- lo.DispatchingStrategyLeast: Distributes messages in the emptiest channel.
- lo.DispatchingStrategyMost: Distributes to the fullest channel.

Some strategies bring fallback, in order to favor non-blocking behaviors. See implementations.

For custom strategies, just implement the lo.DispatchingStrategy prototype

```
Running example:
comsumer 0 gets msg 0
comsumer 3 gets msg 3
comsumer 1 gets msg 1
comsumer 2 gets msg 2
comsumer 4 gets msg 4
comsumer 4 gets msg 9
comsumer 1 gets msg 6
comsumer 3 gets msg 8
comsumer 2 gets msg 7
comsumer 0 gets msg 5
comsumer 0 gets msg 10
comsumer 1 gets msg 11
comsumer 4 gets msg 14
comsumer 3 gets msg 13
comsumer 2 gets msg 12
comsumer 2 gets msg 17
comsumer 1 gets msg 16
comsumer 4 gets msg 19
comsumer 0 gets msg 15
comsumer 3 gets msg 18
closed
closed
closed
closed
closed
Result:
done
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/channel_dispatcher.go:67
```

---
## Demo for channels: slice to channel
> Returns a read-only channels of collection elements. Channel is closed after last element. Channel capacity can be customized.

```
Running example:
1
2
3
4
5
Result:
done
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/slice_to_channel.go:27
```

---
## Demo for channels: channel to slice
> Collects messages from a channel into a slice. Channel is closed after last element.

```
Running example:
Result:
[1 2 3 4 5]
[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/slice_to_channel.go:55
```

---
## Demo for channels: demo for generator
> Implements the generator design pattern. Channel is closed after last element. Channel capacity can be customized.

```
Running example:
Result:
[0 1 1 2 3 5 8 13 21 34]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/generator.go:32
```

---
## Demo for channels: demo for buffer
> Implements the buffer design pattern. Channel is closed after last element. Channel capacity can be customized.

```
Running example:
Result:
items: [1 2 3], buffer length=3, read duration is 1.875µs, channel is open? - true
items: [4 5], buffer length=2, read duration is 625ns, channel is open? - false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/buffer.go:25
```

---
## Demo for channels: demo for buffer with timeout
> Implements the buffer design pattern with timeout. Channel is closed after last element. Channel capacity can be customized.

```
Running example:
Result:
items: [0 1], buffer length=2, read duration is 101.0195ms, channel is open? - true
items: [2 3 4], buffer length=3, read duration is 78.830292ms, channel is open? - true
items: [], buffer length=0, read duration is 1.041µs, channel is open? - false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/buffer.go:55
```

---
## Demo for channels: demo for fan in
> Merge messages from multiple input channels into a single buffered channel. Output messages has no priority. When all upstream channels reach EOF, downstream channel closes.

```
Running example:
Result:
[1 1 1 3 3 3 3 3 2 2 2 2 2 1 1]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/fan.go:25
```

---
## Demo for channels: demo for fan out
> Broadcasts all the upstream messages to multiple downstream channels. When upstream channel reach EOF, downstream channels close. If any downstream channels is full, broadcasting is paused.

```
Running example:
Result:
[1 2 3 4 5]
[1 2 3 4 5]
[1 2 3 4 5]
[1 2 3 4 5]
[1 2 3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/channels/fan.go:45
```

---
## Demo for intersection: demo for contains
> Returns true if an element is present in a collection.

```
Running example:
Result:
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/contains.go:19
```

---
## Demo for intersection: demo for contains by
> Returns true if the predicate function returns true.

```
Running example:
Result:
false
true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/contains.go:36
```

---
## Demo for intersection: demo for every
> Returns true if all elements of a subset are contained into a collection or if the subset is empty.

```
Running example:
Result:
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/every.go:19
```

---
## Demo for intersection: demo for every by
> Returns true if the predicate function returns true for all elements of a subset.

```
Running example:
Result:
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/every.go:36
```

---
## Demo for intersection: demo for some
> Returns true if at least one element of a subset is contained into a collection.

```
Running example:
Result:
false
true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/some.go:19
```

---
## Demo for intersection: demo for some by
> Returns true if the predicate function returns true for at least one element of a subset.

```
Running example:
Result:
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/some.go:36
```

---
## Demo for intersection: demo for none
> Returns true if none of the elements of a subset are contained into a collection.

```
Running example:
Result:
true
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/none.go:19
```

---
## Demo for intersection: demo for none by
> Returns true if the predicate function returns false for all elements of a subset.

```
Running example:
Result:
false
true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/none.go:36
```

---
## Demo for intersection: demo for intersect
> Returns a new collection containing all elements that are present in all given collections.

```
Running example:
Result:
[3 4 5]
[]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/intersect.go:20
```

---
## Demo for intersection: demo for difference
> Returns the difference between two collections.
- The first value is the collection of element absent of list2.
- The second value is the collection of element absent of list1.

```
Running example:
Result:
[1 2] [6]
[1 2 3 4 5] [6 7 8 9]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/intersect.go:39
```

---
## Demo for intersection: demo for union
> Returns all distinct elements from given collections. Result will not change the order of elements relatively.

```
Running example:
Result:
[1 2 3 4 5 6 69]
[1 2 3 4 5 6 7 8 9]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/intersect.go:56
```

---
## Demo for intersection: demo for without
> Returns a collection without the elements of a subset.

```
Running example:
Result:
[1 2 5]
[1 2 3 4]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/without.go:19
```

---
## Demo for intersection: demo for without empty
> Deprecated: Use lo.Compact instead. Returns slice excluding empty values.

```
Running example:
Result:
[1 3 5]
[1 2 3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/intersection/without.go:36
```

---
## Demo for search: demo for index of
> Returns the index at which the first occurrence of a value is found in an array or return -1 if the value cannot be found.

```
Running example:
Result:
2
-1
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/index.go:21
```

---
## Demo for search: demo for last index of
> Returns the index at which the last occurrence of a value is found in an array or return -1 if the value cannot be found.

```
Running example:
Result:
3
-1
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/index.go:40
```

---
## Demo for search: demo for find
> Search an element in a slice based on a predicate. It returns element and true if element was found.

```
Running example:
Result:
2 true
0 false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:20
```

---
## Demo for search: demo for find index of
> FindIndexOf searches an element in a slice based on a predicate and returns the index and true. It returns -1 and false if the element is not found.

```
Running example:
demo for search
```

---
## Demo for search: demo for find last index of
> FindLastIndexOf searches an element in a slice based on a predicate and returns the index and true. It returns -1 and false if the element is not found.

```
Running example:
Result:
3 3 true
0 -1 false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:47
```

---
## Demo for search: demo for find or else
> FindOrElse searches an element in a slice based on a predicate and returns the element if found. It returns the default value if the element is not found.

```
Running example:
Result:
2
8848
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:64
```

---
## Demo for search: demo for find key
> Returns the key of the first value matching.

```
Running example:
Result:
ctrue
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:81
```

---
## Demo for search: demo for find key by
> Returns the key of the first value matching the predicate.

```
Running example:
Result:
btrue
false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:98
```

---
## Demo for search: demo for find uniques
> Returns a slice with all the unique elements of the collection. The order of result values is determined by the order they occur in the array.

```
Running example:
Result:
[4 5]
[1 2 3 4 5]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:115
```

---
## Demo for search: demo for find uniques by
> Returns a slice with all the unique elements of the collection. The order of result values is determined by the order they occur in the array.

```
Running example:
Result:
[]
[3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:132
```

---
## Demo for search: demo for find duplicates
> Returns a slice with all the duplicate elements of the collection.

```
Running example:
Result:
[1 2 3]
[]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:149
```

---
## Demo for search: demo for find duplicates by
> Returns a slice with all the duplicate elements of the collection.

```
Running example:
Result:
[1 2]
[1 2]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/find.go:166
```

---
## Demo for search: demo for min
> Returns the minimum element in a collection.

```
Running example:
Result:
1
1
0
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:22
```

---
## Demo for search: demo for min by
> Search the minimum value of a collection using the given comparison function.
If several values of the collection are equal to the smallest value, returns the first such value.
Returns zero value when the collection is empty.

```
Running example:
Result:
sit
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:44
```

---
## Demo for search: demo for earliest
> Search the minimum time.Time of a collection.

```
Running example:
Result:
0001-01-01 00:00:00 +0000 UTC
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:62
```

---
## Demo for search: demo for earliest by
> Search the minimum time.Time of a collection using the given comparison function.

```
Running example:
Result:
{{0 0 <nil>}}
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:88
```

---
## Demo for search: demo for max
> Returns the maximum element in a collection.

```
Running example:
Result:
5
5
0
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:104
```

---
## Demo for search: demo for max by
> Search the maximum value of a collection using the given comparison function.

```
Running example:
Result:
lorem
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:124
```

---
## Demo for search: demo for latest
> Search the maximum time.Time of a collection.

```
Running example:
Result:
2024-08-15 17:42:45.005862 +0800 +08 m=+1.034297001
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:142
```

---
## Demo for search: demo for latest by
> Search the maximum time.Time of a collection using the given comparison function.

```
Running example:
Result:
{{13954281697065351968 1050503001 0x100f70700}}
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/min.go:168
```

---
## Demo for search: demo for first
> Returns the first element in a collection.

```
Running example:
Result:
1
true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/first.go:19
```

---
## Demo for search: demo for first or empty
> Returns the first element in a collection or zero value if the collection is empty.

```
Running example:
Result:
1
0
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/first.go:33
```

---
## Demo for search: demo for first or
> Returns the first element in a collection or a default value.

```
Running example:
Result:
1
8848
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/first.go:52
```

---
## Demo for search: demo for last
> Returns the last element in a collection.

```
Running example:
Result:
5
true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/first.go:71
```

---
## Demo for search: demo for last or empty
> Returns the last element in a collection or zero value if the collection is empty.

```
Running example:
Result:
5
0
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/first.go:87
```

---
## Demo for search: demo for last or
> Returns the last element in a collection or a default value.

```
Running example:
Result:
5
8848
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/first.go:106
```

---
## Demo for search: demo for nth
> Returns the nth element in a collection.

```
Running example:
Result:
3
<nil>
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/sample.go:19
```

---
## Demo for search: demo for sample
> Returns a random sample of elements from a collection.

```
Running example:
Result:
3
[5 2 3]
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/search/sample.go:33
```

---
## Demo for conditional: demo for conditional statements
> demo for conditional statements

```
Running example:
Result:
1
2
1
1
2
3
1
1
2
3
1
1
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/conditional/conditional.go:23
```

---
## Demo for manipulation: demo for manipulation
> demo for manipulation

```
Running example:
Result:
true
true
0x1400018c5b0
<nil>
<nil>
&[]
0x1400018c5d0
1
1
42
[0x14000184018 0x14000184020 0x14000184028]
[1 2 3]
[hello world]
[1 2 3] true
{ 0}
true
true
hello worldtrue
hello world
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/manipulation/manipulation.go:27
```

---
## Demo for function: demo for partial
> demo for partial

```
Running example:
Result:
11
20
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/function/partial.go:28
```

---
## Demo for concurrency: demo for attempt
> Invokes a function N times until it returns valid output. Returning either the caught error or nil. When first argument is less than 1, the function runs until a successful response is returned.

```
Running example:
Result:
5 error
11 <nil>
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/attempt.go:23
```

---
## Demo for concurrency: demo for attempt with delay
> Invokes a function N times with a delay until it returns valid output. Returning either the caught error or nil. When first argument is less than 1, the function runs until a successful response is returned.

```
Running example:
error and wait for 125ns
error and wait for 201.029917ms
error and wait for 402.121709ms
error and wait for 602.724917ms
error and wait for 803.908667ms
error and wait for 41ns
error and wait for 200.453666ms
error and wait for 401.839125ms
error and wait for 603.21225ms
error and wait for 803.675708ms
error and wait for 1.004945625s
error and wait for 1.206059291s
error and wait for 1.406657125s
error and wait for 1.607693875s
error and wait for 1.808765708s
Result:
5 804.218084ms error
11 2.014077291s <nil>
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/attempt.go:48
```

---
## Demo for concurrency: demo for attempt while
> Invokes a function repeatedly until it returns true. Returning either the caught error or nil. When the predicate function returns false, the function stops.

```
Running example:
Result:
2 retryable error
6 non-retryable error
6 non-retryable error
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/attempt.go:74
```

---
## Demo for concurrency: demo for attempt while with delay
> Invokes a function with a delay until it returns true. Returning either the caught error or nil. When the predicate function returns false, the function stops.

```
Running example:
retryable error and wait for 42ns
retryable error and wait for 201.151792ms
retryable error and wait for 83ns
retryable error and wait for 205.137167ms
retryable error and wait for 405.55475ms
retryable error and wait for 606.751042ms
retryable error and wait for 807.184708ms
non-retryable error and wait for 1.008335417s
retryable error and wait for 42ns
retryable error and wait for 200.704834ms
retryable error and wait for 401.757792ms
retryable error and wait for 602.504209ms
retryable error and wait for 804.3005ms
non-retryable error and wait for 1.005693792s
Result:
2 201.316708ms retryable error
6 1.008395875s non-retryable error
6 1.00583475s non-retryable error
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/attempt.go:103
```

---
## Demo for concurrency: demo for debounce
> NewDebounce creates a debounced instance that delays invoking functions given until after wait milliseconds have elapsed, until cancel is called.

```
Running example:
call once
will be debounced, if called multiple times within 10ms
call multiple times
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
will be debounced, if called multiple times within 10ms
cancel, nothing will be printed
Result:
done
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/debounce.go:51
```

---
## Demo for concurrency: demo for debounce by
> count 让回调函数知道在防抖期间事件被触发了多少次, 而不仅仅是知道事件发生了. NewDebounceBy creates a debounced instance for each distinct key, that delays invoking functions given until sed, until cancel is called.

```
Running example:
键 'C' 被按下 1 次
键 'B' 被按下 2 次
键 'A' 被按下 4 次
Result:
done
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/debounce.go:85
```

---
## Demo for concurrency: demo for synchronize
> Wraps the underlying callback in a mutex. It receives an optional mutex.

```
Running example:
Result:
true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/sync.go:37
```

---
## Demo for concurrency: demo for async
> Executes a function in a goroutine and returns the result in a channel.

```
Running example:
work2
work0
work1
work1
Result:
{}
1
1
{2 <nil>}
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/sync.go:74
```

---
## Demo for concurrency: demo for transact
> Executes multiple functions in a single goroutine and returns the results in a channel.

```
Running example:
step 1
step 2
step 3
rollback 2
rollback 1
step 1
step 2
step 3
Result:
-5
too small
167
<nil>
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/sync.go:133
```

---
## Demo for concurrency: demo for wait for
> Runs periodically until a condition is validated.

```
Running example:
Result:
1 2.263417ms true
10 10.138917ms false
7 7.126834ms true
2 10.605459ms false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/wait_for.go:27
```

---
## Demo for concurrency: demo for wait for with context
> Runs periodically until a condition is validated or context is done.

```
Running example:
Result:
iterations: 1, duration: 2.256917ms, ok: true
iterations: 10, duration: 10.003792ms, ok: false
iterations: 6, duration: 6.1255ms, ok: true
iterations: 2, duration: 10.53075ms, ok: false
iterations: 7, duration: 31.317ms, ok: true
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/concurrency/wait_for.go:72
```

---
## Demo for error handling: Validate
> Helper function that creates an error when a condition is not met.

```
Running example:
Result:
Slice should be empty but contains [a]
<nil>
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/error_handling/validate.go:22
```

---
## Demo for error handling: ErrorAs
> A shortcut for:

err := doSomething()
var rateLimitErr *RateLimitError
if ok := errors.As(err, &rateLimitErr); ok {
// retry later
}

```
Running example:
Result:
my error true
 false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/error_handling/validate.go:60
```

---
## Demo for error handling: Must
> Wraps a function call to panics if second argument is error or false, returns the value otherwise.

```
Running example:
Result:
2022-01-15 00:00:00 +0000 UTC
1 2 3
2022-01-15 00:00:00 +0000 UTC
1 2 3
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/error_handling/must.go:31
```

---
## Demo for error handling: Try
> Calls the function and returns false in case of error and panic.

```
Running example:
Result:
false
true
false
false
true
false
8848 false
1 true
8848 false
1 2 3 false
1 2 3 true
1 2 3 false
errorfalse
<nil> true
error false
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/error_handling/try.go:20
```

---
## Demo for error handling: TryCatch
> Calls the function and returns the error in case of error.

```
Running example:
catch: error
Result:
done
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/error_handling/try.go:62
```

---
## Demo for error handling: TryCatchWithErrorValue
> The same behavior as TryWithErrorValue, but calls the catch function in case of error.

```
Running example:
catch: trigger an error
Result:
done
Source: /Users/bytedance/Desktop/Projects/2024/q3/lo-learn/error_handling/try.go:84
```