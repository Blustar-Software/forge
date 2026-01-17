// Challenge 71: Enum Pattern Matching
// Use a switch with a where clause.

enum Event {
    case temperature(Int)
    case error(String)
}

let event = Event.temperature(1600)

switch event {
case .temperature(let temp) where temp >= 1500:
    print("Overheated")
case .temperature:
    print("Normal")
case .error:
    print("Error")
}
// Print "Normal" for other temperature events
// Print "Error" for error events