struct Mold {
    var size: Int
}

let original = Mold(size: 1)
var copy = original
copy.size = 2

print(original.size)
print(copy.size)