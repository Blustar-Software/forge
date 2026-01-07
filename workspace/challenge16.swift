// Challenge 16: Integration Challenge 1
// Use multiple concepts together

// TODO: Create a variable 'hammerHits' with the value 2
var hammerHits = 2
// TODO: Create a function 'totalHits' that multiplies hits by 3 and returns the result
func totalHits(hits: Int) -> Int {
    hits * 3
}
// TODO: Call totalHits and store the result
hammerHits = totalHits(hits: hammerHits)
// TODO: Print "Total hits: <result>" using string interpolation
print("Total hits: \(hammerHits)")
