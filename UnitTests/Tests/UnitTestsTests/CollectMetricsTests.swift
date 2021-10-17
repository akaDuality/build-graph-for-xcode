import XCTest
@testable import UnitTests

final class TestReportSeekerTests: XCTestCase {
    
    let dodoPizzaFolder = "/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza"
    let codeMetricsFolder = "/Users/yaroslavbredikhin/code-metrics-ios"
    
    func testSomething() throws {
        let settingsParser = BuildSettingsParser(projectURL: URL(string: dodoPizzaFolder)!)
        let derivedDataURL = try XCTUnwrap(settingsParser.settings?.derivedDataDir)
        
        let foundReports = try FileManager.default.findInDirectory(url: derivedDataURL, by: "xcresult")
        
        let projectReports = foundReports.filter {
            $0.path
                .lowercased()
                .contains(settingsParser.settings?.projectName?.lowercased() ?? "")
        }
        
        
        print(projectReports)
    }
     
    
    func test_collectNumberOfUnitTest() {
        let reportModel = Collector().collectUnitTestMetrics(projectPath: dodoPizzaFolder)
        
        do {
            print(try XCTUnwrap(reportModel))
        } catch {
            XCTFail("Metrics is nil")
        }
    }
}


