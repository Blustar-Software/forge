// Challenge 42: Dictionary Iteration
// Print inventory items in a stable order.

let inventory = ["Iron": 3, "Gold": 1]

for key in inventory.keys.sorted() {
    if let count = inventory[key] {
        print("\(key): \(count)")
    }
}
// TODO: Print "<metal>: <count>" for each item