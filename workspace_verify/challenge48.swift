func wear(_ durability: inout Int) {
    durability -= 1
}

var durability = 5
wear(&durability)
print(durability)