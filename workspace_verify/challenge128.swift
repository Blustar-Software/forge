// Challenge 128: Reference Semantics
// Show that classes share references.

class Bellows {
    var power: Int
    init(power: Int) {
        self.power = power
    }
}

let primary = Bellows(power: 1)
let secondary = primary

secondary.power = 3
print(primary.power)
// TODO: Print 'primary.power'