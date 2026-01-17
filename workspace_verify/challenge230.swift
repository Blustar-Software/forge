let numbers = [1, 2, 3, 4, 5, 6]

let total = numbers.lazy
    .filter { $0 % 2 == 0 }
    .map { $0 * 10 }
    .reduce(0, +)

print("Total: \(total)")