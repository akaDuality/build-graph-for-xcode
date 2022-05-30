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
        XCTAssertEqual(parser.depsPath?.absoluteString.split(separator: "/").last,
                       "e9f65ec2d9f99e7a6246f6ec22f1e059-targetGraph.txt")
    }
    
    func testNumberExtraction() {
        let result = DepsPathExtraction(rootURL: URL(fileURLWithPath: "root"))
            .number(from: "Build description signature: b4416238eb7eecbe4969bbd303f28fe5\rBuild description path: /Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Build/Intermediates.noindex/XCBuildData/b4416238eb7eecbe4969bbd303f28fe5-desc.xcbuild\r")
        
        XCTAssertEqual(result, "b4416238eb7eecbe4969bbd303f28fe5")
    }
    
    // TODO: No events for current filter isn't a problem. Other settings can reveal events
}

