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

    func test_whenParseBefore14_3Format_shouldFindPathToDependency() throws {
        let parser = RealBuildLogParser()
        
        let testBundle = TestBundle()
        let _ = try parser.parse(
            projectReference: testBundle.simpleClean.project,
            filter: .shared)
        
        
        XCTAssertEqual(parser.depsPath?.absoluteString.split(separator: "/").last,
                       "e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
        
        let XCBuildData = URL(fileURLWithPath:
                                    "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/Snapshot.framework/Resources/SimpleClean.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData")
        XCTAssertEqual(
            parser.depsPath,
            XCBuildData
            .appendingPathComponent("e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
        )
    }
    
    func test_whenParse14_3Format_shouldFindPathToDependency() throws {
        let parser = RealBuildLogParser()
        
        let testBundle = TestBundle()
        let _ = try parser.parse(
            projectReference: testBundle.xcode14_3.project,
            filter: .shared)
        
        let XCBuildData = URL(fileURLWithPath:
                                    "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Intermediates.noindex/XCBuildData")
        XCTAssertEqual(
            parser.depsPath,
            XCBuildData
            .appendingPathComponent("584b872b7e96316afd6ba1f3a3c43f43.xcbuilddata/target-graph.txt")
        )
    }
}

