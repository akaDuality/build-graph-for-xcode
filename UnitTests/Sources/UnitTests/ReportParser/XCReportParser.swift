import Foundation
import FileAnalyzer

struct XCReportParser {
    func parseReport(path: String) -> ReportOld {
        let jsonReport = getReportJSON(xcResultPath: path)
        
        do {
            let reportData = jsonReport.data(using: .utf16) ?? Data()
            var report = try JSONDecoder().decode(ReportOld.self, from: reportData)
            
            if let testsRefId = report.actions._values.first?.actionResult.testsRef?.id.value {
                let jsonTestsReport = getTestsRef(xcResultPath: path, id: testsRefId)
                let jsonTestsData = jsonTestsReport.data(using: .utf16) ?? Data()
                let testsRef = try JSONDecoder().decode(TestsRef.self, from: jsonTestsData)
                report.tests = testsRef
            }
            
            return report
        } catch let error {
            fatalError("Error when parsing XCResult file: \(error)")
        }
    }
    
    private func getReportJSON(xcResultPath: String) -> String {
        let command = "xcrun xcresulttool get --path \(xcResultPath) --format json"
        let commandOutput = shell(command)
        return cleanupJSON(json: commandOutput)
    }
    
    private func cleanupJSON(json: String) -> String {
        // удоляем текст с варнингами в начале джейсона: триммим всё начало до первой строки с '{'
        var jsonLines = json.split(separator: "\n")
        while jsonLines.first != "{" {
            if jsonLines.count == 0 {
                return json
            }
            jsonLines.removeFirst()
        }
        return json
    }
    
    private func getTestsRef(xcResultPath: String, id: String) -> String {
        let command = "xcrun xcresulttool get --path \(xcResultPath) --format json --id \(id)"
        let commandOutput = shell(command)
        return cleanupJSON(json: commandOutput)
    }
}

struct TestsRef: Codable {
    let summaries: SummariesArray
}

struct SummariesArray: Codable {
   
}
