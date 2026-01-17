// Challenge 31: Metrics Practice
// Practice min/max/average counting in a loop.

let weights = [3, 5, 7, 4]

var minWeight = weights[0]
var maxWeight = weights[0]
var sum = 0
var heavyCount = 0

for weight in weights {
    if weight < minWeight { minWeight = weight }
    if weight > maxWeight { maxWeight = weight }
    sum += weight
    if weight >= 5 { heavyCount += 1 }
}

let average = sum / weights.count

print("Min: \(minWeight)")
print("Max: \(maxWeight)")
print("Average: \(average)")
print("Heavy: \(heavyCount)")
// TODO: Find the maximum value (start with weights[0] and update)
// TODO: Compute the average (sum then divide by weights.count)
// TODO: Count values >= 5
// TODO: Print results as:
// "Min: 3"
// "Max: 7"
// "Average: 4"
// "Heavy: 2"