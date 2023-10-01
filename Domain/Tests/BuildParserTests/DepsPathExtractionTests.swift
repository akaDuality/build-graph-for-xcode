//
//  DepsPathExtractionTests.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 20.05.2023.
//

import Foundation
import XCTest
@testable import BuildParser

// MARK: - New version
class DepsPathExtractionTests: XCTestCase {
    
    func test_pathFromSectionText() {
        let sut = DepsPathExtraction()
        let sectionText = "Build description signature: 9bf52d084a567b4e77074ec13b3364ab\rBuild description path: /Users/mikhail/Library/Developer/Xcode/DerivedData/DodoPizza-grkipvsgskordwctxiipkuhrvwfb/Build/Intermediates.noindex/ArchiveIntermediates/DodoPizza/IntermediateBuildFilesPath/XCBuildData/9bf52d084a567b4e77074ec13b3364ab.xcbuilddata\r"
        let path = sut.path(sectionText: sectionText)
        
        XCTAssertNotNil(path)
        
        let expectedURL = URL(fileURLWithPath: "/Users/mikhail/Library/Developer/Xcode/DerivedData/DodoPizza-grkipvsgskordwctxiipkuhrvwfb/Build/Intermediates.noindex/ArchiveIntermediates/DodoPizza/IntermediateBuildFilesPath/XCBuildData/9bf52d084a567b4e77074ec13b3364ab.xcbuilddata/target-graph.txt")
        XCTAssertEqual(path, expectedURL)
    }
    
    // Don't know what is exact version. Probably Xcode 14.3-15
    func testNumberExtraction2() {
        let sut = DepsPathExtraction()
        let sectionText = "Build description signature: 56b40cd4d98fa9450c9d285b429da116\rBuild description path: /Users/mikhail/Library/Developer/Xcode/DerivedData/VoiceOver_Designer-hdaabgdqcsawyycaqzpnlvclcdrb/Build/Intermediates.noindex/XCBuildData/56b40cd4d98fa9450c9d285b429da116.xcbuilddata\r"
        let path = sut.path(sectionText: sectionText)
        
        let expectedURL = URL(fileURLWithPath: "/Users/mikhail/Library/Developer/Xcode/DerivedData/VoiceOver_Designer-hdaabgdqcsawyycaqzpnlvclcdrb/Build/Intermediates.noindex/XCBuildData/56b40cd4d98fa9450c9d285b429da116.xcbuilddata/target-graph.txt")
        XCTAssertEqual(path, expectedURL)
    }
}

// MARK: - Old version
class DepsPathExtractionTests_old: XCTestCase {
    func testNumberExtraction() {
        let result = DepsPathExtraction_old(rootURL: URL(fileURLWithPath: "root"))
            .number(from: "Build description signature: b4416238eb7eecbe4969bbd303f28fe5\rBuild description path: /Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Build/Intermediates.noindex/XCBuildData/b4416238eb7eecbe4969bbd303f28fe5-desc.xcbuild\r")
        
        XCTAssertEqual(result, "b4416238eb7eecbe4969bbd303f28fe5")
    }
}
