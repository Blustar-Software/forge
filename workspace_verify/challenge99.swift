// Challenge 99: Unique Ingots
// Use a set to track unique values.

var ingots: Set<String> = ["Iron"]

ingots.insert("Iron")
ingots.insert("Gold")
print(ingots.contains("Gold"))
// TODO: Print whether the set contains "Gold"