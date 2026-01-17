struct ForgeReport {
    var id: Int
    lazy var summary: String = "Report \(id)"
}

var report = ForgeReport(id: 1)
print(report.summary)