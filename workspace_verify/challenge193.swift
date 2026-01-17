protocol Stack<Element> {
    associatedtype Element
    var items: [Element] { get }
}

struct IntStack: Stack {
    let items: [Int]
}

let stack: any Stack<Int> = IntStack(items: [1, 2, 3])
print("Top: \(stack.items.last ?? 0)")