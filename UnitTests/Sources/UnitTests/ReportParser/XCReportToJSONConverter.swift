import Foundation
import FileAnalyzer

struct XCReportToJSONConverter {
    public func getReportJSON(xcResultPath: URL) -> URL {
        var urlForJSONFile = xcResultPath.deletingPathExtension().appendingPathExtension("json")
        urlForJSONFile = URL(string: "file://" + urlForJSONFile.path)!
        let command = "xcrun xcresulttool get --path \(xcResultPath.path) --format json > \(urlForJSONFile.path)"
        let _ = shell(command)
        return urlForJSONFile
    }
    
    public func getTestsRefJSON(xcResultPath: URL, id: String) -> URL {
        let reportName = xcResultPath.deletingPathExtension().lastPathComponent
        let urlForJSONFile = xcResultPath.deletingLastPathComponent().appendingPathComponent(reportName + "_TestsRef.json")
        let command = "xcrun xcresulttool get --path \(xcResultPath) --format json --id \(id) > \(urlForJSONFile.path)"
        let _ = shell(command)
        return urlForJSONFile
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
}
