//
//  ParsingTests.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 28.04.2022.
//

import XCTest
@testable import BuildParser
import Snapshot

class ParsingTests: XCTestCase {

    func testExample() throws {
        let parser = RealBuildLogParser()
        
        let filter = FilterSettings()
        filter.cacheVisibility = .all
        
        let project = try parser
            .parse(projectReference: TestBundle().simpleClean.project,
                   filter: .shared)
        
        XCTAssertEqual(project.events.count, 12) // TODO: There was 14
        
        XCTAssertEqual(
            parser.depsPath?.path,
            "/Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/Snapshot.framework/Resources/SimpleClean.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData/e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
    }
    
    // TODO: No events for current filter isn't a problem. Other settings can reveal events
}

