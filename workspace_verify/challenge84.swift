func readTemp(_ value: String?) {
    guard let value = value, let temp = Int(value) else {
        print("Invalid")
        return
    }
    print("Temp: \(temp)")
}

readTemp("abc")