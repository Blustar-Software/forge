In Swift, a **set** is used to store unique elements of the same data type.

## Syntax

```
var setName = Set<Type>()

var setName: Set = [value1, value2, ...]
```

`Type` refers to the [data type](https://www.codecademy.com/resources/docs/swift/data-types) of the values to be stored in the set.

To create a set populated with values, use the `Set` keyword before the assignment operator. The values of the set must be contained within brackets `[]` and separated with commas `,`.

## Empty Sets

An empty set is a set that contains no values inside.

```
var team = Set<String>()

print(team)
// Output: []
```

## Iterating Over a Set

A `for` - `in` loop can be used to iterate over each item in a set.

```
var recipe: Set = ["Chocolate chips", "Eggs", "Flour", "Sugar"]

for ingredient in recipe {
  print("Include \(ingredient) in the recipe.")
}
```

## .isEmpty Property

Use the built-in property `.isEmpty` to check if a set has no values contained in it.

```
var emptySet = Set<String>()

print(emptySet.isEmpty)  // Prints: true

var populatedSet: Set = [1, 2, 3]

print(populatedSet.isEmpty) // Prints: false
```

## .count Property

The property `.count` returns the number of elements contained within a set.

```
var band: Set = ["Guitar", "Bass", "Drums", "Vocals"]

print("There are \(band.count) players in the band.")
// Output: There are 4 players in the band.
```

### Methods

There are many set manipulation methods available in the Swift Standard Library, including generic `Collection` -based methods. Some of these include testing the contents of sets (e.g. `.contains()` and `.isEmpty`) while others can modify or manipulate the set entirely (e.g., `.map()`, `.reduce()`, and `.sorted()`). There is also a list of methods applicable to a pair of sets (e.g., `.intersection()` or `.subtracting()`).

Below are some methods available for sets:

## Sets

[.contains()](https://www.codecademy.com/resources/docs/swift/sets/contains)

Checks whether an item exists within the set.

[.count](https://www.codecademy.com/resources/docs/swift/sets/count)

Calculates the total number of existing elements in a set.

[.insert()](https://www.codecademy.com/resources/docs/swift/sets/insert)

Adds an element at a specified index.

[.intersection()](https://www.codecademy.com/resources/docs/swift/sets/intersection)

Returns a new set of elements with the overlapping elements of two sets.

[.isEmpty](https://www.codecademy.com/resources/docs/swift/sets/isEmpty)

Returns a Boolean indicating whether a Set is empty, based on whether it contains elements or not.

[.isSubset()](https://www.codecademy.com/resources/docs/swift/sets/isSubset)

Checks whether all elements of a set are present in another set.

[.isSuperset()](https://www.codecademy.com/resources/docs/swift/sets/isSuperset)

Returns a boolean telling whether every element of a given set exists in another set.

[.remove()](https://www.codecademy.com/resources/docs/swift/sets/remove)

Removes and returns a specified element from a set.

[.removeAll()](https://www.codecademy.com/resources/docs/swift/sets/removeAll)

Removes every item from a Set in Swift.

[.subtracting()](https://www.codecademy.com/resources/docs/swift/sets/subtracting)

Returns a new set containing the elements from the target set that are not in the given set.

[.symmetricDifference()](https://www.codecademy.com/resources/docs/swift/sets/symmetricDifference)

Returns a new set with all the elements from two sets that do not overlap.

[.union()](https://www.codecademy.com/resources/docs/swift/sets/union)

Returns a new set containing all elements of one set combined with the elements of a given set.
