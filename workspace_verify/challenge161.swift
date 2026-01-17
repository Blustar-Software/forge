// Challenge 161: Protocol Parameter
// Accept a protocol type.

protocol HeatSource {
    var heat: Int { get }
}

struct Furnace: HeatSource {
    let heat: Int
}

func reportHeat(source: HeatSource) {
    print("Heat: \(source.heat)")
}

reportHeat(source: Furnace(heat: 1500))
// TODO: Call it with a Furnace(heat: 1500)