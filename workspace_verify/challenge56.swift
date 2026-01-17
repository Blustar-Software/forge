// Challenge 56: Closure Arguments
// Call a function that takes a closure.

func transform(_ value: Int, using closure: (Int) -> Int) {
    print(closure(value))
}

transform(5, using: { (value: Int) -> Int in
    return value * 3
})
// Multiply the value by 3