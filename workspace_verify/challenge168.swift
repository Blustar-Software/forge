protocol Stackable {
    associatedtype Item
    var items: [Item] { get set }
    mutating func push(_ item: Item)
}

struct Stack<T>: Stackable {
    var items: [T]

    mutating func push(_ item: T) {
        items.append(item)
    }
}

var stack = Stack(items: [])
stack.push(2)
print(stack.items.count)