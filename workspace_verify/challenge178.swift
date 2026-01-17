import Foundation

@MainActor
func updateStatus(value: Int) -> String {
    return "Status: \(value)"
}

Task { @MainActor in
    let status = updateStatus(value: 3)
    print(status)
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))