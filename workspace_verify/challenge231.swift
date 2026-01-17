func maxValue<T: Comparable>(_ a: T, _ b: T) -> T {
    return a > b ? a : b
}

print(maxValue(4, 9))