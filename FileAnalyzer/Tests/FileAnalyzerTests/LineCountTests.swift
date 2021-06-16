    import XCTest
    @testable import FileAnalyzer
    
    final class LineCountTests: XCTestCase {
        let srcRoot: URL = "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/"
        
        func testExample() throws {
            // Overall
            try LineCount(folder: srcRoot).read()
            try LineCount(folder: srcRoot.appendingPathComponent("Common/")).read()
            
            // App
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/Domain/")).read()
            try LineCount(folder: srcRoot.appendingPathComponent("DodoPizza/Module/")).read()
        }
    }
    
    extension URL: ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        
        public init(stringLiteral value: String) {
            self = URL(string: value)!
        }
    }
