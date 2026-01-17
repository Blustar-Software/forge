// Challenge 96: Skip Weak Ore
// Use continue and break.

let strengths = [1, 2, 0, 3]
var processed = 0

for strength in strengths {
    if strength == 0 {
        continue
    }
    processed += 1
    if processed == 2 {
        break
    }
}

print(processed)
// TODO: Skip values that are 0
// TODO: Count 'processed' values
// TODO: Stop after processing 2 values
// TODO: Print 'processed'