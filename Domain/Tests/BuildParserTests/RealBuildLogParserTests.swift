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

    var parser: RealBuildLogParser!
    var testBundle: TestBundle!
    
    override func setUp() {
        super.setUp()
        
        parser = RealBuildLogParser()
        testBundle = TestBundle()
    }

    override func tearDown() {
        parser = nil
        testBundle = nil
        
        super.tearDown()
    }

    func test_whenParseBefore14_3Format_shouldFindPathToDependency() throws {
        let _ = try parser.parse(
            projectReference: testBundle.simpleClean.project,
            filter: .shared)
        
        XCTAssertEqual(parser.depsPath?.url.absoluteString.split(separator: "/").last,
                       "e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")

        let resources = URL(fileURLWithPath: "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/BuildParserTests.xctest/Contents/Resources/Domain_Snapshot.bundle/Contents/Resources/")
        let XCBuildData = resources.appendingPathComponent("SimpleClean.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData")
        
        XCTAssertNoDifference_path(
            parser.depsPath?.url,
            XCBuildData
            .appendingPathComponent("e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
        )
    }
    
    func test_whenParse14_3Format_shouldFindPathToDependency() throws {
        let _ = try parser.parse(
            projectReference: testBundle.xcode14_3.project,
            filter: .shared)
        
        let resources = URL(fileURLWithPath: "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/BuildParserTests.xctest/Contents/Resources/Domain_Snapshot.bundle/Contents/Resources/")
        let XCBuildData = resources.appendingPathComponent("Xcode14.3.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData")
        
        XCTAssertNotNil(parser.depsPath) // TODO: Путь в логе лежит абсолютный, а не относительный для файла.
        XCTAssertNoDifference_path(
            parser.depsPath?.url,
            XCBuildData
            .appendingPathComponent("584b872b7e96316afd6ba1f3a3c43f43.xcbuilddata/target-graph.txt")
        )
    }
    
    // TODO: Give a name
    func testExample() throws {
        let parser = RealBuildLogParser()
        
        let filter = FilterSettings()
        filter.cacheVisibility = .all
        
        let project = try parser
            .parse(projectReference: TestBundle().simpleClean.project,
                   filter: .shared)
        
        XCTAssertEqual(project.events.count, 12) // TODO: There was 14
        
        // Relative path because SampleClean is placed at user's location in runtime
        let path = "/Resources/SimpleClean.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData/e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt"
        
        XCTAssertNoDifference_path(
            parser.depsPath?.url,
            URL(fileURLWithPath:
                    "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/BuildParserTests.xctest/Contents/Resources/Domain_Snapshot.bundle/Contents/Resources/SimpleClean.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData/e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt"))
        
        XCTAssertTrue(parser.depsPath?.url.path.hasSuffix(path) ?? false)
    }
    
    // TODO: No events for current filter isn't a problem. Other settings can reveal events
}

import CustomDump
func XCTAssertNoDifference_path(
    _ lhsURL: URL?,
    _ rhsURL: URL?,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertNoDifference(
        lhsURL?.pathComponents,
        rhsURL?.pathComponents,
        file: file,
        line: line
    )
}
