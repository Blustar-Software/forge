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

runAsync {
    let task = Task<Int, Never> {
        await Task.yield()
        if Task.isCancelled {
            return 0
        }
        return 3
    }

    task.cancel()
    let result = await task.value
    print("Cancelled: \(result)")
}