protocol DataSource {
    func values() -> [Int]
}

struct MemorySource: DataSource {
    let items: [Int]
    func values() -> [Int] { items }
}

struct Analyzer {
    let source: DataSource
    func sum() -> Int {
        return source.values().reduce(0, +)
    }
}

let analyzer = Analyzer(source: MemorySource(items: [1, 2, 3]))
print("Sum: \(analyzer.sum())")