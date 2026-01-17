enum TempError: Error {
    case outOfRange
}

func checkTemp(_ temp: Int) throws -> Int {
    if temp < 0 {
        throw TempError.outOfRange
    }

    return temp
}

let result = try? checkTemp(-1)
print(String(describing: result))