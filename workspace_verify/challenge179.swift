import Foundation

struct HeatReport: Sendable {
    let value: Int
}

let report = HeatReport(value: 1200)
print("Heat: \(report.value)")