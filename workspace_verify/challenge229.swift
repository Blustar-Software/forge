struct Ore {
    let name: String
    let purity: Int
}

let ores = [
    Ore(name: "Iron", purity: 70),
    Ore(name: "Gold", purity: 90),
]

let values = ores.map(\.purity)
let average = values.reduce(0, +) / values.count
print("Average: \(average)")