// Challenge 151: Conditional Conformance
// Add conditional conformance to a generic type.

struct Crate<T> {
    let items: [T]
}

extension Crate: Equatable where T: Equatable {}

let first = Crate(items: [1, 2])
let second = Crate(items: [1, 2])
print(first == second)
// TODO: Compare two crates of Ints and print the result