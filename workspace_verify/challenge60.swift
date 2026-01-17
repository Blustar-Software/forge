func makeCounter() -> () -> Void {
    var count = 0
    return {
        count += 1
        print(count)
    }
}

let counter = makeCounter()
counter()
counter()
counter()