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

@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

actor Furnace {
    @Clamped(0...2000) var heat: Int = 0

    func addHeat(_ value: Int) {
        heat += value
    }

    func currentHeat() -> Int {
        return heat
    }
}

let furnace = Furnace()
runAsync {
    await furnace.addHeat(2200)
    let current = await furnace.currentHeat()
    print("Heat: \(current)")
}