// Challenge 31: Metrics Practice
// Practice min/max/average counting in a loop.

let weights = [3, 5, 7, 4]

// TODO: Find the minimum value (start with weights[0] and update)
// TODO: Find the maximum value (start with weights[0] and update)
// TODO: Compute the average (sum then divide by weights.count)
// TODO: Count values >= 5
// TODO: Print results as:
// "Min: 3"
// "Max: 7"
// "Average: 4"
// "Heavy: 2"
var min = weights[0]
var max = weights[0]
var sum = 0
var heavy = 0

for weight in weights {
    if weight < min {
        min = weight
    }
    
    if weight > max {
        max = weight
    }
    
    sum += weight
    
    if weight >= 5 {
        heavy += 1
    }
}

let average = sum / weights.count

print("Min: \(min)")
print("Max: \(max)")
print("Average: \(average)")
print("Heavy: \(heavy)")
