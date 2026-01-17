struct ForgeLog {
    let metal: String
    let heat: Int
}

let log = ForgeLog(metal: "Iron", heat: 1200)
let mirror = Mirror(reflecting: log)

for child in mirror.children {
    if let label = child.label {
        print(label)
    }
}