// Challenge 64: min/max
// Find the smallest and largest temperatures.

let temps = [1200, 1500, 1600, 1400]

let minTemp = temps.min() ?? 0
let maxTemp = temps.max() ?? 0
print(minTemp)
print(maxTemp)
// TODO: Use max() to find the largest temp (default to 0 if nil)
// TODO: Print min then max on separate lines