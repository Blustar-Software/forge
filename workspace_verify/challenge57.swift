// Challenge 57: Trailing Closures
// Use a closure to transform values.

func transform(_ value: Int, using closure: (Int) -> Int) {
    print(closure(value))
}

transform(5) { (value: Int) -> Int in
    return value * 3
}
// Multiply the value by 3