import Foundation

@propertyWrapper
struct Tracked {
    private var value: Int
    private(set) var projectedValue: Int = 0

    var wrappedValue: Int {
        get { value }
        set { value = newValue; projectedValue += 1 }
    }

    init(wrappedValue: Int) {
        value = wrappedValue
    }
}

struct Furnace {
    @Tracked var heat = 1200
}

var furnace = Furnace()
furnace.heat = 1300
furnace.heat = 1400
print("Updates: \(furnace.$heat)")