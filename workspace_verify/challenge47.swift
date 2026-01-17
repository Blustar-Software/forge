func averageTemp(_ temps: Int...) {
    var total = 0
    for temp in temps {
        total += temp
    }
    let average = total / temps.count
    print(average)
}

averageTemp(1000, 1200, 1400)