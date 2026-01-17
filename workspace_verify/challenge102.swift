// Challenge 102: Iterate Ledger
// Sum values in a dictionary.

let ledger = ["Iron": 2, "Gold": 1]
var total = 0

for (_, count) in ledger {
    total += count
}

print(total)
// TODO: Print 'total'