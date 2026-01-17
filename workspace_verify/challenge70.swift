enum Event {
    case temperature(Int)
    case error(String)
}

let tempEvent = Event.temperature(1500)
let errorEvent = Event.error("Overheat")

switch tempEvent {
case .temperature(let value):
    print("Temp: \(value)")
case .error(let message):
    print("Error: \(message)")
}

switch errorEvent {
case .temperature(let value):
    print("Temp: \(value)")
case .error(let message):
    print("Error: \(message)")
}