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
        let metrics = Collector().collectUnitTestMetrics(projectPath: dodoPizzaFolder)
        
        do {
            print(try XCTUnwrap(metrics.debugDescription))
        } catch {
            XCTFail("Metrics is nil")
        }
    }
    
    func test_readFile() {
        let url = URL(string: "file:///Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-gywhgqgvgbkrhpcdhsseznxsokbp/Logs/Test/Test-AllTests-2021.10.07_17-43-08-+0300.xcresult")!
        
        do {
            let data = try Data(contentsOf: url)
            print(data.count)
        } catch let error {
            print(error)
        }
        
    }
}


