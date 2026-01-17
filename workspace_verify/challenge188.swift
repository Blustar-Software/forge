import Foundation

struct Counter: Sequence {
    let start: Int
    func makeIterator() -> CounterIterator {
        return CounterIterator(current: start)
    }
}

struct CounterIterator: IteratorProtocol {
    var current: Int
    mutating func next() -> Int? {
        guard current > 0 else { return nil }
        defer { current -= 1 }
        return current
    }
}

let sequence = Counter(start: 3)
let items = Array(sequence)
print("Count: \(items.count)")
print("Last: \(items.last ?? 0)")