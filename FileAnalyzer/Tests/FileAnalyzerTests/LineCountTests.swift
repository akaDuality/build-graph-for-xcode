    import XCTest
    @testable import FileAnalyzer
    
    final class LineCountTests: XCTestCase {
        
        let projectsFolder: URL = "/Users/rubanov/Documents/Projects/"
        
        func testPizza() throws {
            let srcRoot: URL = projectsFolder.appendingPathComponent("dodo-mobile-ios/DodoPizza/")
            
            // Overall
            try LineCount(folder: srcRoot).read(project: .pizza)
            try LineCount(folder: srcRoot.appendingPathComponent("DCommon/")).read()
            
            // App
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/Domain/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/Module/")).read()
        }
        
        func testDoner() throws {
            let srcRoot: URL = projectsFolder.appendingPathComponent("doner-mobile-ios/")
            
            try LineCount(folder: srcRoot).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Sources/")).read()

            try LineCount(folder: srcRoot.appendingPathComponent("Pods/")).read()
        }
        
        func testDrinkit() throws {
            let srcRoot: URL = projectsFolder.appendingPathComponent("drinkit-mobile-ios")
            
            try LineCount(folder: srcRoot).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Core/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Pods/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Sources/")).read()
        }
    }
    
    extension URL: ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        
        public init(stringLiteral value: String) {
            self = URL(string: value)!
        }
    }
