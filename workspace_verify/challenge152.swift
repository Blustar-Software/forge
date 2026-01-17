protocol StatusProviding {
    var status: String { get }
}

extension StatusProviding {
    func report() {
        print(status)
    }
}

struct Alloy: StatusProviding {
    let status: String
}

let alloy = Alloy(status: "Alloy ready")
alloy.report()