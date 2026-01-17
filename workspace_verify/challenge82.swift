// Challenge 82: Running Total
// Add values until the total reaches a limit.

let temps = [900, 1000, 1200, 1500]
var total = 0

for temp in temps {
    total += temp
    if total >= 2500 {
        break
    }
}

print(total)
// TODO: If 'total' >= 2500, break
// TODO: Print 'total'