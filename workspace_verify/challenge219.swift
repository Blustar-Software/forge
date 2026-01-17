var value = 42

withUnsafePointer(to: &value) { pointer in
    print(pointer.pointee)
}