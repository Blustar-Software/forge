// Challenge 138: Protocol Composition
// Use multiple protocol requirements.

protocol Fueling {
    var fuel: Int { get }
}

protocol Venting {
    var airflow: Int { get }
}

struct Vent: Fueling, Venting {
    let fuel: Int
    let airflow: Int
}

func report(_ source: Fueling & Venting) {
    print(source.fuel)
    print(source.airflow)
}

let vent = Vent(fuel: 2, airflow: 3)
report(vent)
// TODO: Print fuel and airflow on separate lines