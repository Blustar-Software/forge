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

func makeStream() -> AsyncStream<Int> {
    return AsyncStream { continuation in
        continuation.yield(1)
        continuation.yield(2)
        continuation.yield(3)
        continuation.finish()
    }
}

runAsync {
    var total = 0
    let stream = makeStream()

    for await value in stream {
        total += value
    }

    print("Total: \(total)")
}