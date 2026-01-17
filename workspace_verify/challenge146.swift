struct Box<T> {
    let value: T
}

let box = Box(value: 7)
print(box.value)