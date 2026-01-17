protocol Sensor {
    var name: String { get }
}

struct TempSensor: Sensor { let name = "Temp" }
struct PressureSensor: Sensor { let name = "Pressure" }

func report(_ sensors: [any Sensor]) {
    for sensor in sensors {
        print(sensor.name)
    }
}

let sensors: [any Sensor] = [TempSensor(), PressureSensor()]
report(sensors)