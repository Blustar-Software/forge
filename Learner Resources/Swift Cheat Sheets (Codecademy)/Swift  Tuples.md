---
title: "Swift | Tuples"
source: "https://www.codecademy.com/resources/docs/swift/tuples"
author:
  - "[[Codecademy]]"
published: 2021-11-17
created: 2025-12-27
description: "Compounds multiple values into a single value."
tags:
  - "clippings"
---
**Tuples** are a data structure introduced in [Swift 4.0](https://www.swift.org/blog/swift-4.0-released/). It is used to group multiple values, separated by commas `,`, into a single value that is enclosed in parentheses `()`.

> **Note:** Tuples are compound types. This means that they can combine different types of data.

## Syntax

```
var myTuple = (value1, value2, ...)
```

> **Note:** Variable names and property names in Swift should follow the [API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and be in lowerCamelCase.

## Accessing and Changing Values

Values of a tuple can be accessed using indices:

```
var computerScience = (1960, "George Forsythe")

print(computerScience.0)
// Output: 1960

print(computerScience.1)
// Output: George Forsythe
```

Values or elements can also be referenced with a named property:

```
var alanTuring = (
  name: "Alan Mathison Turing",
  born: 1912,
  inventions: ["Universal Turing Machine", "Bombe"]
)

print("\(alanTuring.name) was born in \(alanTuring.born) and invented the \(alanTuring.inventions[0]).")
// Alan Mathison Turing was born in 1912 and invented the Universal Turing Machine.
```

These values can then be altered through their indices or name:

```
computerScience.0 = 1961
print(computerScience.0)
// Output: 1961

alanTuring.inventions.append("Automatic Computing Engine")
print(alanTuring.inventions)
// Output: ["Universal Turing Machine", "Bombe", "Automatic Computing Engine"]
```
