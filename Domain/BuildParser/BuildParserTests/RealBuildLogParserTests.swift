//
//  RealBuildLogParser.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import XCTest
import BuildParser
import Snapshot

class RealBuildLogParserTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let parser = RealBuildLogParser()
        
        let testBundle = TestBundle()
        let project = try parser.parse(
            projectReference: testBundle.simpleClean.project,
            filter: .shared)
        
        XCTAssertEqual(parser.depsPath?.absoluteString.split(separator: "/").last,
                       "e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
    }
}

