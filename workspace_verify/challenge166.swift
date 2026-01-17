struct Box<T> {
    let value: T
}

let box = Box(value: "Iron")
print(box.value)