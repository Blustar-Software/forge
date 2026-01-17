// Challenge 144: Error Integration
// Use errors in an API surface.

enum FurnaceError: Error {
    case tooCold
}

protocol Heatable {
    func heat(to level: Int) throws
}

struct Furnace: Heatable {
    func heat(to level: Int) throws {
        if level < 1000 {
            throw FurnaceError.tooCold
        }
    }
}

do {
    try Furnace().heat(to: 900)
} catch {
    print("Too cold")
}
// TODO: Call it with a low value and print "Too cold" in catch