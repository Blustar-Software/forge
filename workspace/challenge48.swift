// Challenge 48: inout Parameters
// Simulate tool wear.

// TODO: Create a function 'wear' that subtracts 1 from a passed-in Int
func wear(_ durability: inout Int) {
    durability -= 1
}

// TODO: Create a variable 'durability' = 5
// TODO: Call wear on durability
// TODO: Print durability
var durability = 5
wear(&durability)
print(durability)
