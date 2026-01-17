func makeSequence() -> AnySequence<Int> {
    return AnySequence([1, 2, 3])
}

let sequence = makeSequence()
let items = Array(sequence)
print("Count: \(items.count)")