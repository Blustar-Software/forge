import Foundation

struct Countdown: Sequence {
    let start: Int
    func makeIterator() -> CountdownIterator {
        return CountdownIterator(current: start)
    }
}

struct CountdownIterator: IteratorProtocol {
    var current: Int
    mutating func next() -> Int? {
        guard current > 0 else { return nil }
        defer { current -= 1 }
        return current
    }
}

let countdown = Countdown(start: 3)
for value in countdown {
    print(value)
}