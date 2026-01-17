func areEqual<T>(_ a: T, _ b: T) -> Bool where T: Equatable {
    return a == b
}

print(areEqual(4, 4))