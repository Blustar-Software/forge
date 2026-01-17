// Challenge 63: reduce
// Sum forge temperatures.

let temps = [1000, 1200, 1400]

let total = temps.reduce(0) { partial, temp in
    partial + temp
}
print(total)
// TODO: Print the total