import Foundation

@propertyWrapper
struct Lowercased {
    private var value: String

    var wrappedValue: String {
        get { value }
        set { value = newValue.lowercased() }
    }

    init(wrappedValue: String) {
        value = wrappedValue.lowercased()
    }
}

struct Label {
    @Lowercased var name: String
}

let label = Label(name: "IRON")
print(label.name)