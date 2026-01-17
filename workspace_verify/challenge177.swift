import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let group = DispatchGroup()
    group.enter()
    Task {
        await operation()
        group.leave()
    }
    group.wait()
}

actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func current() -> Int {
        return value
    }
}

let counter = Counter()
runAsync {
    await counter.increment()
    await counter.increment()
    let value = await counter.current()
    print("Count: \(value)")
}