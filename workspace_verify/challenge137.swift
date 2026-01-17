// Challenge 137: Protocol as Type
// Use a protocol in a function signature.

protocol HeatSource {
    var heat: Int { get }
}

struct Burner: HeatSource {
    let heat: Int
}

func reportHeat(source: HeatSource) {
    print(source.heat)
}

let burner = Burner(heat: 1200)
reportHeat(source: burner)
// TODO: Call it with a Burner