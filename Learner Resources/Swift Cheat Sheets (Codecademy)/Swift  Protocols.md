A **protocol** is a collection of methods, properties, and rules that a `class`, `struct`, or `enum` can adopt.

## Syntax

A protocol is created with the `protocol` keyword:

```
protocol protocolName {
  // Protocol body
}
```

> **Note:** Names are written in PascalCase.

For class, structure, or enumeration data types to adopt a protocol, it chains onto their definition and is separated with a colon:

```
class MyClass: MyProtocol, OtherProtocol, ... {
  // This can be a class, structure, or enumeration
}
```

## Property Requirements

Property requirements are variables that indicate a type and the `get` / `set` keywords determine if that property is gettable and/or settable.

```
protocol MyProtocol {
  var getAndSet: Int { get set }
  var onlyGet: String { get }
}
```

> **Note:** Gettable variables can be read and settable variables can be set or changed. Programmers sometimes only allow a variable to be gettable because they don’t want it to be mutated.

Data types that adopt a protocol, must conform to the properties and methods defined in it.

```
protocol Grammar {
  var alphabet: String { get }
}

struct Language: Grammar {
  var alphabet: String
}

let english = Language(alphabet: "abcdefghijklmnopqrstuvwxyz")

print(english.alphabet)
// Output: abcdefghijklmnopqrstuvwxyz
```

## Built-in Protocols

Swift includes certain built-in protocols.

### CaseIterable

[`CaseIterable`](https://developer.apple.com/documentation/swift/caseiterable) has an `allCases` property. An enumeration can adopt this protocol to gain access to all its values.

```
enum MageAdvancementTree: CaseIterable {
  case novice, firstJob, secondJob, thirdJob, fourthJob
}
print("You will have \(MageAdvancementTree.allCases.count) different jobs as a Mage.")
// Output: You will have 5 different jobs as a Mage.
```

## Protocols

[CodingKey](https://www.codecademy.com/resources/docs/swift/protocols/codingkey)

Enables the mapping of JSON object keys to the given Swift model properties.

[CodingKeyRepresentable](https://www.codecademy.com/resources/docs/swift/protocols/codingkeyrepresentable)

A protocol that dictates the use of a key type that can encode and decode from a KeyedContainer.

[Comparable](https://www.codecademy.com/resources/docs/swift/protocols/comparable)

Protocol in Swift used to define a sort order for instances of a type.

[Decodable](https://www.codecademy.com/resources/docs/swift/protocols/decodable)

A Swift protocol that enables the conversion of data.

[Decoder](https://www.codecademy.com/resources/docs/swift/protocols/decoder)

Converts external data into Swift types.

[Encodable](https://www.codecademy.com/resources/docs/swift/protocols/encodable)

Enables object data to be encoded for use with Application Programming Interfaces.

[Equatable](https://www.codecademy.com/resources/docs/swift/protocols/equatable)

Enables two instances of a type to be compared for equality.

[Hashable](https://www.codecademy.com/resources/docs/swift/protocols/hashable)

Allows types to be hashed into integer values.

[Identifiable](https://www.codecademy.com/resources/docs/swift/protocols/identifiable)

A protocol in Swift that requires conforming types to have a unique identifier property.

[SingleValueEncodingContainer](https://www.codecademy.com/resources/docs/swift/protocols/singlevalueencodingcontainer)

Supports the storage and direct encoding of a single non-keyed value.
