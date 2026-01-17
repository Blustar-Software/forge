protocol Metal {
    var name: String { get }
}

struct Ingot: Metal {
    let name: String
}

func makeMetal() -> some Metal {
    return Ingot(name: "Iron")
}

let metal = makeMetal()
print("Metal: \(metal.name)")