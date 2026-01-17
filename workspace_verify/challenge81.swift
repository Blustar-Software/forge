// Challenge 81: Count Multiples
// Count numbers divisible by 3.

let numbers = [1, 2, 3, 4, 5, 6]
var count = 0

for number in numbers {
    if number % 3 == 0 {
        count += 1
    }
}

print(count)
// TODO: If a number is divisible by 3, increment 'count'
// TODO: Print 'count'