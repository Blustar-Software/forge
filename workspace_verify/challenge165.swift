// Challenge 165: Error Route
// Throw and catch a custom error.

enum ForgeError: Error {
    case jam
}

func start(fuel: Int) throws {
    if fuel == 0 {
        throw ForgeError.jam
    }
}

do {
    try start(fuel: 0)
} catch {
    print("Jam")
}
// TODO: Call it with fuel 0 and print "Jam" in catch