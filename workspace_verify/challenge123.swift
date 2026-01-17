struct Hammer {
    var strikes: Int

    func summary() -> String {
        return "Strikes: \(strikes)"
    }
}

var hammer = Hammer(strikes: 0)
print(hammer.summary())