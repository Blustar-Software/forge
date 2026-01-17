import Foundation

struct Ore {
    let name: String
    let purity: Int
}

let ore = Ore(name: "Iron", purity: 90)
let nameKey = \Ore.name
print(ore[keyPath: nameKey])