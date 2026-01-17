struct Press {
    var force: Int

    var doubleForce: Int {
        get { force * 2 }
        set { force = newValue / 2 }
    }
}

var press = Press(force: 2)
press.doubleForce = 10
print(press.force)