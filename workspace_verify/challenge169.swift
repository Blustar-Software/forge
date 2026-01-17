extension Array where Element: Equatable {
    func allSame() -> Bool {
        guard let first = first else { return true }
        return allSatisfy { $0 == first }
    }
}

print([1, 1, 2].allSame())