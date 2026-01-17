func minValue<T: Comparable>(_ first: T, _ second: T) -> T {
    return first <= second ? first : second
}

print(minValue(3, 5))