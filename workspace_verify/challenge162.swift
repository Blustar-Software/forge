// Challenge 162: Composition Drill
// Require two protocols in one parameter.

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

func report(_ vent: Fueling & Venting) {
    print("Fuel \(vent.fuel)")
    print("Air \(vent.airflow)")
}

report(Vent(fuel: 2, airflow: 3))
// TODO: Print "Fuel <fuel>" and "Air <airflow>" on separate lines