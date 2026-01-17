struct Report {
    var id: Int
    lazy var title: String = "Report \(id)"
}

var report = Report(id: 2)
print(report.title)