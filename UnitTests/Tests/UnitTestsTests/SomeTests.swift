    import XCTest
    @testable import UnitTests
    
    final class TestReportSeekerTests: XCTestCase {
        
        let dodoPizzaFolder = "/Users/yaroslavbredikhin/dodo-mobile-ios/DodoPizza"
        
        func testSomething() throws {
            let settingsParser = BuildSettingsParser(projectURL: URL(string: dodoPizzaFolder)!)
            let derivedDataURL = try XCTUnwrap(settingsParser.settings?.derivedDataDir)
            
            let foundReports = try FileManager.default.findInDirectory(url: derivedDataURL, by: "xcresult")
            
            let pfojectName = settingsParser
            let projectReports = foundReports.filter {
                $0.path
                    .lowercased()
                    .contains(settingsParser.settings?.project?.lowercased() ?? "")
            }
            
            
            print(projectReports)
        }
        
        
    }
    
    
