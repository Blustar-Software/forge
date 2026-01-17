// Challenge 78: Integration Challenge
// Process forge logs with advanced tools.

let lines = ["1200", "x", "1500", "1600", "bad", "1400"]

let values = lines.map { Int($0) }
let temps = values.compactMap { $0 }
let hotTemps = temps.filter { $0 >= 1500 }
let total = hotTemps.reduce(0) { $0 + $1 }
print(total)
// TODO: Use compactMap to remove nils
// TODO: Use filter to keep temps >= 1500
// TODO: Use reduce to compute total
// TODO: Print the total