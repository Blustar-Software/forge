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

func forgeName() async -> String {
    return "Forged"
}

runAsync {
    let task = Task { await forgeName() }
    let result = await task.value
    print(result)
}