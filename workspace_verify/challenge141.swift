// Challenge 141: Default Implementations
// Provide default behavior with a protocol extension.

protocol Reportable {
    var message: String { get }
}

extension Reportable {
    func printReport() {
        print(message)
    }
}

struct Report: Reportable {
    let message: String
}

let report = Report(message: "Report ready")
report.printReport()
// TODO: Conform a struct and call 'printReport()'