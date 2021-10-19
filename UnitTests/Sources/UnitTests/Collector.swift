import Foundation

struct Collector {
    let converter = XCResultToJSONConverter()
    
    func collectUnitTestMetrics(projectPath: String) -> Report? {
        let settingsParser = BuildSettingsParser(projectURL: URL(string: projectPath)!)
        
        guard let derivedDataURL = getDerivedDataPath(parser: settingsParser),
              let projectName = getProjectName(parser: settingsParser),
              let lastTestReport = getLastTestReport(for: projectName,
                                                     derivedDataURL: derivedDataURL) else {
            return nil
        }
        
        let reportJSONURL = converter.getReportJSON(xcResultPath: lastTestReport)
        var reportModel: Report?
        
        do {
            let failParser = JSONFailParser(filePath: reportJSONURL)
            reportModel = try failParser.parse()
        } catch let error {
            print(error)
        }
        
        let allTestNames = findAllTests(path: lastTestReport, id: reportModel?.testsRefId() ?? "")
        reportModel?.testNames = allTestNames
        
        return reportModel
    }
    
    private func getDerivedDataPath(parser settingsParser: BuildSettingsParser) -> URL? {
        guard let derivedDataURL = settingsParser.settings?.derivedDataDir else {
            print("Derived data url not parsed")
            return nil
        }
        print("Derived data path: \(derivedDataURL)")
        
        return derivedDataURL
    }
    
    private func getProjectName(parser settingsParser: BuildSettingsParser) -> String? {
        guard let projectName = settingsParser.settings?.projectName else {
            print("Project not determined")
            return nil
        }
        print("Project name: \(projectName)")
        
        return projectName
    }
    
    private func findAllTestReports(in derivedDataPath: URL) -> [URL] {
        guard let allFoundReports = try? FileManager.default.findInDirectory(url: derivedDataPath, by: "xcresult"),
              allFoundReports.count > 0 else {
            print("No test reports found")
            return []
        }
        print("\(allFoundReports.count) test reports found: \n\t\(allFoundReports.map({ $0.lastPathComponent }))")
        
        return allFoundReports
    }
    
    private func getLastTestReport(for projectName: String,
                                   derivedDataURL: URL) -> URL? {
        let allFoundReports = findAllTestReports(in: derivedDataURL)
        
        let projectSpecificReports = allFoundReports.filter {
            $0.path
                .lowercased()
                .contains(projectName.lowercased())
        }
        
        guard let lastReport = projectSpecificReports.last else {
            print("Last test report weren't found")
            return nil
        }
        print("Last test report: \(lastReport.absoluteString)")
        
        return lastReport
    }
    
    private func findAllTests(path: URL, id: String) -> [String] {
        let jsonFilePath = converter.getTestsRefJSON(xcResultPath: path, id: id)
        var json = ""
        do {
            json = String(data: try Data(contentsOf: jsonFilePath), encoding: .utf8) ?? ""
        } catch let error {
            print(error)
        }
        
        let expression = "(?m)^.*\"_value\"\\s:\\s\"(.*/.*\\(\\))\""
        let names = json.match(expression).compactMap { $0.last }
        
        return names
    }
}

extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}
