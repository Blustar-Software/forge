// Challenge 26: Break and Continue
// Print numbers 1 to 4, skipping 3

// TODO: Loop from 1 to 5
// - Skip 3 using continue
// - Stop when you hit 5 using break
// - Print the other numbers
for num in 1...5 {
    switch num {
    case 3:
        continue
    case 5:
        break
    default:
        print(num)
    }
}
