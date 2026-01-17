var value = 5

withUnsafeMutablePointer(to: &value) { pointer in
    pointer.pointee += 5
}

print(value)