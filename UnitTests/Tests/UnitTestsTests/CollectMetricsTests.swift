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
        let reportModel = Collector().extractLastReport(from: dodoPizzaFolder)
        
        do {
            print(try XCTUnwrap(reportModel))
        } catch {
            XCTFail("Metrics is nil")
        }
    }
    
    func test_diffTwoTestResultFiles() {
        let reportModel1 = Collector().extractReport(from: URL(string: "/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-gywhgqgvgbkrhpcdhsseznxsokbp/Logs/Test/Test-AllTests-2021.11.15_13-01-52-+0300.xcresult")!)
        let reportModel2 = Collector().extractReport(from: URL(string: "/Users/yaroslavbredikhin/Library/Developer/Xcode/DerivedData/DodoPizza-gywhgqgvgbkrhpcdhsseznxsokbp/Logs/Test/Test-AllTests-2021.11.18_12-27-08-+0300.xcresult")!)
        
        XCTAssertEqual(reportModel1?.testNames, reportModel2?.testNames)
    }
}


