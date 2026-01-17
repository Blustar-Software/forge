import Foundation

func runAsync(_ operation: @escaping () async -> Void) {
    let semaphore = DispatchSemaphore(value: 0)
    Task {
        await operation()
        semaphore.signal()
    }

    while semaphore.wait(timeout: .now()) != .success {
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
    }
}

func fetchHeat() async -> Int {
    return 1500
}

runAsync {
    let value = await fetchHeat()
    print("Heat: \(value)")
}