func process(_ value: Int) {
    func isValid(_ value: Int) -> Bool {
        return value >= 0
    }
    if isValid(value) {
        print("OK")
    } else {
        print("Invalid")
    }
}

process(-1)