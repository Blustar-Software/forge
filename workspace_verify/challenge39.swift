func printHeat(value: Int?) {
    guard let value = value else {
        print("No heat")
        return
    }
    print(value)
}

printHeat(value: nil)