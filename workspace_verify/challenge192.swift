protocol Reader {
    func read() -> Int
}

struct FixedReader: Reader {
    let value: Int
    func read() -> Int { value }
}

struct AnyReader: Reader {
    private let _read: () -> Int

    init<R: Reader>(_ base: R) {
        _read = base.read
    }

    func read() -> Int {
        return _read()
    }
}

let readers: [AnyReader] = [AnyReader(FixedReader(value: 3)), AnyReader(FixedReader(value: 4))]
let total = readers.reduce(0) { $0 + $1.read() }
print("Sum: \(total)")