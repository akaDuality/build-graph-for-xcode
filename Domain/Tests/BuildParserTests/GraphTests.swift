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
    private func layer(snapshotName: String, filter: FilterSettings) throws -> CALayer {
        let snapshot = try TestBundle().snapshot(name: snapshotName)
        
        let project = try parser.parse(projectReference: snapshot.project,
                                       filter: filter)
        
        let layer = AppLayer(events: project.events, relativeBuildStart: 0, fontSize: 10, scale: 1)
        
        layer.frame = CGRect(x: 0,
                             y: 0,
                             width: 500,
                             height: layer.intrinsicContentSize.height)
        layer.backgroundColor = CGColor.white
        
        return layer
    }
    
    private func snapshot(name: String,
                          filter: FilterSettings,
                          testName: String = #function,
                          file: StaticString = #file,
                          line: UInt = #line) throws {
        let layer = try layer(snapshotName: name, filter: filter)
        
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record,
                       file: file,
                       testName: testName,
                       line: line)
    }
    
    // MARK: Tests
    func test_drawingSimpleClean() throws {
        try snapshot(name: "SimpleClean", filter: .shared)
    }
    
    func test_drawingIncrementalWithGap_everything() throws {
        try snapshot(name: "IncrementalWithBigGap", filter: .all)
    }
    
    func test_drawingIncrementalWithGap_cached() throws {
        try snapshot(name: "IncrementalWithBigGap", filter: .cached)
    }
    
    func test_drawingIncrementalWithGap_currentBuild() throws {
        try snapshot(name: "IncrementalWithBigGap", filter: .currentBuld)
    }
}

extension FilterSettings {
    static var currentBuld: FilterSettings {
        let filter = FilterSettings()
        filter.cacheVisibility = .currentBuild
        return filter
    }
    
    static var all: FilterSettings {
        let filter = FilterSettings()
        filter.cacheVisibility = .all
        return filter
    }
    
    static var cached: FilterSettings {
        let filter = FilterSettings()
        filter.cacheVisibility = .cached
        return filter
    }
}
