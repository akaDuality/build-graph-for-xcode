//
//  ParsingTests.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 28.04.2022.
//

import XCTest
@testable import BuildParser

class ParsingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let url = BundleAccess().paymentSDK
        let parser = RealBuildLogParser()
        let project = try parser
            .parse(logURL: url, filter: .shared)
        
        XCTAssertEqual(project.events.count, 14)
        XCTAssertEqual(parser.depsPath, "e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
    }
    
    func testNumberExtraction() {
        let result = DepsPathExtraction().number(from: "Build description signature: b4416238eb7eecbe4969bbd303f28fe5\rBuild description path: /Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Build/Intermediates.noindex/XCBuildData/b4416238eb7eecbe4969bbd303f28fe5-desc.xcbuild\r")
        
        XCTAssertEqual(result, "b4416238eb7eecbe4969bbd303f28fe5")
    }
}

class BundleAccess {
    var paymentSDK: URL {
        Bundle(for: BundleAccess.self)
            .url(forResource: "F5F5EB7C-FD56-4037-9959-7056E5363FCD",
                 withExtension: "xcactivitylog")!
    }
}
