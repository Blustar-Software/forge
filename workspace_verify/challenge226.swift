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
    try? await Task.sleep(nanoseconds: 50_000_000)
    print("Done")
}