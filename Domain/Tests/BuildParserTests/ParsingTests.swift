//
//  ParsingTests.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 28.04.2022.
//

import XCTest
@testable import BuildParser
import Snapshot
import CustomDump

class ParsingTests: XCTestCase {

    func testExample() throws {
        let parser = RealBuildLogParser()
        
        let filter = FilterSettings()
        filter.cacheVisibility = .all
        
        let project = try parser
            .parse(projectReference: TestBundle().simpleClean.project,
                   filter: .shared)
        
        XCTAssertEqual(project.events.count, 12) // TODO: There was 14
        
        XCTAssertNoDifference_path(
            parser.depsPath,
            URL(fileURLWithPath:
                    "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/BuildParserTests.xctest/Contents/Resources/Domain_Snapshot.bundle/Contents/Resources/SimpleClean.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData/e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt"))
    }
    
    // TODO: No events for current filter isn't a problem. Other settings can reveal events
}

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
