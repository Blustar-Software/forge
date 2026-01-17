struct Snapshot: Sendable {
    let values: [Int]
}

let snapshot = Snapshot(values: [1, 2, 3])
print("Count: \(snapshot.values.count)")