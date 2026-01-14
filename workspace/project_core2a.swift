// Core 2 Project A: Forge Log Analyzer
// Analyze a list of forge temperatures
//
// Requirements:
// - Function name: analyzeTemperatures
// - Takes one [Int] parameter labeled temperatures
// - Returns a tuple: (min: Int, max: Int, average: Int, overheatCount: Int)
// - average should use integer division
// - overheatCount should count values >= 1500
// - Use named tuple fields (min, max, average, overheatCount)
//
// Your function will be tested with:
// - [1200, 1500, 1600, 1400]
//
// Expected outputs:
// Min: 1200
// Max: 1600
// Average: 1425
// Overheat: 2

// TODO: Write your 'analyzeTemperatures' function here
func analyzeTemperatures(temperatures: [Int]) -> (min: Int, max: Int, average: Int, overheatCount: Int) {
    var min = temperatures[0]
    var max = temperatures[0]
    var sum = 0
    var overheatCount = 0
    
    for temperature in temperatures {
        if temperature < min { min = temperature }
        if temperature > max { max = temperature }
        sum += temperature
        if temperature >= 1500 { overheatCount += 1 }
    }
    
    let average = sum / temperatures.count
    return (min: min, max: max, average: average, overheatCount: overheatCount)
}

// Test code (don't modify):
let report = analyzeTemperatures(temperatures: [1200, 1500, 1600, 1400])
print("Min: \(report.min)")
print("Max: \(report.max)")
print("Average: \(report.average)")
print("Overheat: \(report.overheatCount)")
