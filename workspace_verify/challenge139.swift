// Challenge 139: Protocol Inheritance
// Inherit requirements from another protocol.

protocol Component {
    var id: String { get }
}

protocol InspectableComponent: Component {
    var status: String { get }
}

struct Sensor: InspectableComponent {
    let id: String
    let status: String
}

let sensor = Sensor(id: "S1", status: "OK")
print(sensor.status)
// TODO: Create a type that conforms and print its status