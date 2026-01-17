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
    let sum = await withTaskGroup(of: Int.self) { group -> Int in
        for value in [1, 2, 3] {
            group.addTask { value }
        }

        var total = 0
        for await value in group {
            total += value
        }
        return total
    }

    print("Sum: \(sum)")
}