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

actor Ledger {
    private var balance = 0

    func add(_ value: Int) {
        balance += value
    }

    func current() -> Int {
        return balance
    }
}

let ledger = Ledger()
runAsync {
    await ledger.add(3)
    await ledger.add(4)
    let value = await ledger.current()
    print("Balance: \(value)")
}