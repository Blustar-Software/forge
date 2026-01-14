// Challenge 17: Integration Challenge 1
// Use multiple concepts together

// TODO: Create a variable 'hammerHits' with the value 2
// TODO: Create a function 'totalHits' that multiplies hits by 3 and returns the result
// TODO: Call totalHits and store the result
// TODO: Print "Total hits: <result>" using string interpolation
var hammerHits = 2
func totalHits(hits: Int) -> Int {
    hits * 3
}

let hitsTotal = totalHits(hits: hammerHits)
print("Total hits: \(hitsTotal)")
