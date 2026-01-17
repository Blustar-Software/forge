// Challenge 134: Static vs Instance
// Use a static property.

struct Shift {
    static let maxHours = 8
    var hours: Int
}

let shift = Shift(hours: 6)
print(Shift.maxHours)
print(shift.hours)
// TODO: Print 'shift.hours'