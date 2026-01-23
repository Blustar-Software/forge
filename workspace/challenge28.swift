// Challenge 28: Break and Continue
// Print numbers 1 to 4, skipping 3

// TODO: Loop from 1 to 5
// - Skip 3 using continue
// - Stop when you hit 5 using break
// - Print the other numbers
for num in 1...5 {
    if num == 3 {
        continue
    } else if num == 5 {
        break
    } else {
        print(num)
    }
}
