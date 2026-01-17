// Challenge 36: Tuple Returns
// Return min and max from a function.

let temps = [3, 5, 2, 6]

func minMax(values: [Int]) -> (min: Int, max: Int) {
    var minValue = values[0]
    var maxValue = values[0]

    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
    }

    return (min: minValue, max: maxValue)
}

let report = minMax(values: temps)
print("Min: \(report.min)")
print("Max: \(report.max)")
// TODO: Call it and print:
// "Min: 2"
// "Max: 6"