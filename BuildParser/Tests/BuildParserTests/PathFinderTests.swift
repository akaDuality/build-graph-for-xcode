//
//  PathFinderTests.swift
//  
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import Foundation
import XCTest
import XCLogParser
import CustomDump

@testable import BuildParser

class PathFinderTests: XCTestCase {
    let logOptions = LogOptions(
        projectName: "",
        xcworkspacePath: "",
        xcodeprojPath: "",
        derivedDataPath: "",
        logManifestPath: "")
    
    var sut: PathFinder!
    
    func test_searchProjects() throws {
        let projects = try sut.projects()
        
        XCTAssertNoDifference(projects, [
            "BuildTime",
            "DodoPizzaTuist",
            "PaymentSDK",
            "DodoPizza",
            "Drinkit",
            "XCLogParser",
            "doner-mobile-ios",
            "CodeMetrics",
            "Unsaved_Xcode_Document",
            "BuildParser",
            "MobileBackend",
            "BuildGant",
            "DemoAppTemplateWorkspace",
            "Prep_Station",
            "PaymentSDK",
            "DemoAppTemplate",
        ])
    }
    
    func test_searchTargetGraph() throws {
        let projectDir = URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData")!
        
        let path = try sut.targetGraph(projectDir: projectDir)
        
        XCTAssertNoDifference(
            URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData/Build/Intermediates.noIndex/XCBuildData/hnthnt-targetGraph.txt"),
            path)
    }
    
    override func setUp() {
        super.setUp()
        
        sut = PathFinder(
            logOptions: logOptions,
            contentsOfDirectory: { path in ["hnthnt-targetGraph.txt"]}
        )
    }
}
