import Foundation

struct HeatIterator: IteratorProtocol {
    var current: Int
    let max: Int

    mutating func next() -> Int? {
        guard current <= max else { return nil }
        defer { current += 100 }
        return current
    }
}

var iterator = HeatIterator(current: 1200, max: 1400)
print(iterator.next()!)
print(iterator.next()!)