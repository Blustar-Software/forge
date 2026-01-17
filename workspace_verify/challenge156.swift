struct Weight {
    var kg: Int

    var pounds: Int {
        get { kg * 2 }
        set { kg = newValue / 2 }
    }
}

var weight = Weight(kg: 1)
weight.pounds = 10
print(weight.kg)