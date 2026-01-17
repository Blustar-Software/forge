enum ForgeError: Error {
    case overheated
}

func checkHeat(_ value: Int) throws {
    if value > 2000 {
        throw ForgeError.overheated
    }
}

 do {
    try checkHeat(2200)
    print("OK")
} catch {
    print("Error: overheating")
}