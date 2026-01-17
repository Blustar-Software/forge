import Foundation

struct Ore {
    let name: String
}

let ores = [Ore(name: "Iron"), Ore(name: "Gold")]
let names = ores.map(\.name)
print(names.joined(separator: ","))