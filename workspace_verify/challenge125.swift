struct Crucible {
    var level: Int

    mutating func raise() {
        level += 1
    }
}

var crucible = Crucible(level: 1)
crucible.raise()
crucible.raise()
print(crucible.level)