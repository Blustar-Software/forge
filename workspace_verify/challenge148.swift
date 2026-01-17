protocol Storage {
    associatedtype Item
    var items: [Item] { get }
}

struct StringStorage: Storage {
    let items: [String]
}

let storage = StringStorage(items: ["Iron", "Gold"])
print(storage.items.count)