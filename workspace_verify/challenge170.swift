// Challenge 170: Conditional Conformance
// Conform a generic type when T is Equatable.

struct Wrapper<T> {
    let value: T
}

extension Wrapper: Equatable where T: Equatable {}

let first = Wrapper(value: "A")
let second = Wrapper(value: "A")
print(first == second)
// TODO: Compare two Wrapper(value: "A") and print the result