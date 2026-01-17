class Torch {
    let id: Int
    init(id: Int) {
        self.id = id
    }

    deinit {
        print("Torch \(id) released")
    }
}

var torch: Torch? = Torch(id: 1)
torch = nil