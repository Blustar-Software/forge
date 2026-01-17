// Challenge 61: map
// Transform forge temperatures into strings.

let temps = [1200, 1500, 1600]

let labels = temps.map { "T\($0)" }
print(labels)
// TODO: Print the resulting array