//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 12.10.2021.
//

import XCTest
@testable import BuildParser
import SnapshotTesting
import Snapshot

final class GraphTests: XCTestCase {
    
    let record = false
    
    let parser = RealBuildLogParser()
    
    // MARK: DSL
    private func layer(snapshotName: String) throws -> CALayer {
        let snapshot = try TestBundle().snapshot(name: snapshotName)
        let project = try parser.parse(projectReference: snapshot.project,
                                       filter: .shared)
        
        let layer = AppLayer(events: project.events, relativeBuildStart: 0, fontSize: 10, scale: 1)
        
        layer.frame = CGRect(x: 0,
                             y: 0,
                             width: 500,
                             height: layer.intrinsicContentSize.height)
        layer.backgroundColor = CGColor.white
        
        return layer
    }
    
    private func snapshot(name: String,
                          testName: String = #function,
                          file: StaticString = #file,
                          line: UInt = #line) throws {
        let layer = try layer(snapshotName: name)
        
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record,
                       file: file,
                       testName: testName,
                       line: line)
    }
    
    // MARK: Tests
    func test_drawingSimpleClean() throws {
        try snapshot(name: "SimpleClean")
    }
    
    func test_drawingIncrementalWithGap() throws {
        try snapshot(name: "IncrementalWithBigGap")
        
        // TODO: Draw cache only
        // TODO: Draw incremental build only
    }
}
