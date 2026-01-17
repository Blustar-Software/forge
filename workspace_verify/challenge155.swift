struct Counter {
    var value: Int

    mutating func increment() {
        value += 1
    }
}

var counter = Counter(value: 1)
counter.increment()
counter.increment()
print(counter.value)