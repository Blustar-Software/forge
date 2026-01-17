func label(temp: Int) -> String {
    return "T\(temp)"
}

func printLabel(for temp: Int) {
    print(label(temp: temp))
}

printLabel(for: 1200)