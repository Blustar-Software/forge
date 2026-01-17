// Challenge 58: Inferred Trailing Closures
// Let Swift infer types in a trailing closure.

func transform(_ value: Int, using closure: (Int) -> Int) {
    print(closure(value))
}

transform(6) { value in
    return value * 4
}
// Multiply the value by 4
// Note: You can omit return for a single-expression closure (Challenge 48)