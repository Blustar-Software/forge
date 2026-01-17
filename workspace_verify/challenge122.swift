// Challenge 122: Stored Properties
// Read and update stored properties.

struct Furnace {
    var heat: Int
}

var furnace = Furnace(heat: 1200)

furnace.heat = 1500
print(furnace.heat)
// TODO: Print 'furnace.heat'