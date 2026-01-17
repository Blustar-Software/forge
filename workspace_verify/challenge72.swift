enum TempError: Error {
    case outOfRange
}

func checkTemp(_ temp: Int) throws {
    if temp < 0 {
        throw TempError.outOfRange
    }
}

do {
    try checkTemp(-1)
} catch {
    print("Error")
}