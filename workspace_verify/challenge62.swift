// Challenge 62: filter
// Keep only hot temperatures.

let temps = [1000, 1500, 1600, 1400]

let hot = temps.filter { $0 >= 1500 }
print(hot)
// TODO: Print the filtered array