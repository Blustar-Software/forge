// Challenge 66: flatMap
// Flatten batches.

let batches = [[1, 2], [3], [4, 5]]

let flat = batches.flatMap { $0 }
print(flat)
// TODO: Print the result