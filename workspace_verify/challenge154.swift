// Challenge 154: Struct Copy Drill
// Show independent struct copies.

struct Plate {
    var thickness: Int
}

let original = Plate(thickness: 2)
var copy = original

copy.thickness = 5
print(original.thickness)
print(copy.thickness)
// TODO: Print 'original.thickness' and 'copy.thickness' on separate lines