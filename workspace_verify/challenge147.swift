func maxValue<T: Comparable>(_ first: T, _ second: T) -> T {
    return first >= second ? first : second
}

print(maxValue(3, 5))