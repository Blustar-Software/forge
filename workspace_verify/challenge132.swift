struct Gauge {
    var pressure: Int {
        willSet {
            print("Will set to \(newValue)")
        }
        didSet {
            print("Did set from \(oldValue)")
        }
    }
}

var gauge = Gauge(pressure: 1)
gauge.pressure = 2