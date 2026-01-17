// Challenge 59: Shorthand Closure Syntax II
// Use $0 to shorten a closure.

func apply(_ value: Int, using closure: (Int) -> Int) {
    print(closure(value))
}

apply(4) { $0 + 6 }