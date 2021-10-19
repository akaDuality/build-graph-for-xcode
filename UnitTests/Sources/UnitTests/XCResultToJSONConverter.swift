import Foundation
import FileAnalyzer

struct XCResultToJSONConverter {
    
    /// С помощью xcresulttool парсит корневой объект файла .xcresult в JSON и кладёт рядом в файле '__fileName__.json'
    /// - Parameter xcResultPath: Путь к файлу .xcresult
    /// - Returns: Путь к файлу с JSON
    public func getReportJSON(xcResultPath: URL) -> URL {
        var urlForJSONFile = xcResultPath.deletingPathExtension().appendingPathExtension("json")
        urlForJSONFile = URL(string: "file://" + urlForJSONFile.path)!
        let command = "xcrun xcresulttool get --path \(xcResultPath.path) --format json > \(urlForJSONFile.path)"
        let _ = shell(command)
        return urlForJSONFile
    }
    
    /// С помощью xcresulttool парсит часть файла .xcresult с тестами (TestsRef) в JSON и кладёт рядом в файле '<fileName>_TestsRef.json'
    /// - Parameters:
    ///   - xcResultPath: Путь к файлу .xcresult
    ///   - id: id объекта TestsRef. Нужно получить из корневого объекта xcresult
    /// - Returns: Путь к файлу с JSON
    public func getTestsRefJSON(xcResultPath: URL, id: String) -> URL {
        let reportName = xcResultPath.deletingPathExtension().lastPathComponent
        var urlForJSONFile = xcResultPath.deletingLastPathComponent().appendingPathComponent(reportName + "_TestsRef.json")
        urlForJSONFile = URL(string: "file://" + urlForJSONFile.path)!
        let command = "xcrun xcresulttool get --path \(xcResultPath.path) --format json --id \(id) > \(urlForJSONFile.path)"
        let _ = shell(command)
        return urlForJSONFile
    }
    
    private func cleanupJSON(json: String) -> String {
        // удоляет текст с варнингами в начале джейсона: триммит всё начало до первой строки с '{'
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
