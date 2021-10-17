import Foundation

public class XCResultParser {
    let filePath: URL
    let shell: (_ command: String...) -> Int32
    
    public init(filePath: URL,
                shell: @escaping (_ command: String...) -> Int32) {
        self.filePath = filePath
        self.shell = shell
    }
    
    public func parse() throws -> URL {
//        guard filePath.startAccessingSecurityScopedResource() else {
//            // Handle the failure here.
//            throw Error.noAccess
//        }
//
//        // Make sure you release the security-scoped resource when you are done.
//        defer { filePath.stopAccessingSecurityScopedResource() }
        
        let reportFileName = "report.json"
        let reportPath = filePath.deletingLastPathComponent().appendingPathComponent(reportFileName)
        
        let command = "xcrun xcresulttool get --path \(filePath.path) --format json"
        _ = self.shell(command)
        
        return reportPath
    }
    
    enum Error: Swift.Error {
        case noAccess
    }
}

public class ReportParser {
    let filePath: URL

    public init(filePath: URL) {
        self.filePath = filePath
    }

    public func parseList() throws -> String {
        let parser = JSONFailParser(filePath: filePath)
        
        let report = try parser.parse()
        
        let failedTests = try report.failedNames()
        let failedTestsFormatted = formattedReport(failedTests)

        return failedTestsFormatted
    }

    public func parseTotalTests() throws -> String {
        let parser = JSONFailParser(filePath: filePath)
        let report = try parser.parse()

        return report.total()
    }

    public func parseFailedTests() throws -> String {
        let parser = JSONFailParser(filePath: filePath)
        let report = try parser.parse()

        return report.failed()
    }

    public func parseSkippedTests() throws -> String {
        let parser = JSONFailParser(filePath: filePath)
        let report = try parser.parse()

        return report.skipped()
    }

    public func parse(mode: ParserMode) throws -> String {
        switch mode {
        case .total:
            return try parseTotalTests()
        case .skipped:
            return try parseSkippedTests()
        case .failed:
            return try parseFailedTests()
        case .list:
            return try parseList()
        }
    }
}

class FileParser {
    let filePath: URL
    
    init(filePath: URL) {
        self.filePath = filePath
    }
    
    func data() throws -> Data {
        try Data(contentsOf: filePath)
    }
}

class JSONFailParser: FileParser {
    
    func parse() throws -> Report {
        let report: Report = try JSONDecoder().decode(Report.self, from: data())
        return report
    }
}

func formattedReport(_ input: [String]) -> String {
    let pairs = input.map { fullName -> Test in
        let parts = fullName.split(separator: ".")
        return Test(suit: String(parts[0]),
                    name: String(parts[1]))
    }
    
    let suits = Dictionary(grouping: pairs) { pair in
        pair.suit
    }
    .map({ (key: String, values: [Test]) in
        Suit(name: key, tests: values.map({ test in test.name }))
    })
    
    let groups2 = suits
        .map  { suit in
            SuitDescr(name: suit.name, tests: suitDescription(suit: suit))
        }
        .sorted { SuitDescr1, SuitDescr2 in
            SuitDescr1.name < SuitDescr2.name
        }
            
    
    return groups2.map({ suitDescr in
        suitDescr.tests
    }).joined(separator: "\n\n")
}

func suitDescription(suit: Suit) -> String {
    """
\(suit.name):
\(suitTests(suit.tests))
"""
}

public enum ParserMode: String {
    case total = "total"
    case skipped = "skipped"
    case failed = "failed"
    case list = "list"
}
