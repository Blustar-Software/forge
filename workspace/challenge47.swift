// Challenge 47: Variadics
// Accept multiple temperatures.

// TODO: Create a function 'averageTemp' that takes any number of Ints
// TODO: Sum the values and divide by the count (integer division)
// TODO: Print the average
func averageTemp(temps: Int ... ) {
    var sum = 0
    for temp in temps {
        sum += temp
    }
    let average = sum / temps.count
    print(average)
}

// TODO: Call averageTemp with 1000, 1200, 1400
averageTemp(temps: 1000, 1200, 1400)
