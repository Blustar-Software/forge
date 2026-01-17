struct Box<T> {
    let value: T
}

extension Box where T == Int {
    func isEven() -> Bool {
        return value % 2 == 0
    }
}

let box = Box(value: 6)
print(box.isEven())