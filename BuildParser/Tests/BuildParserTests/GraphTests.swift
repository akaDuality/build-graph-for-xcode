//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 12.10.2021.
//

import XCTest
@testable import BuildParser
import SnapshotTesting

final class GraphTests: XCTestCase {
    
    let record = false
    
    let parser = XcodeBuildTimesParser()
    
    func test_drawingAppEvents() throws {
        throw XCTSkip("too slow")
        let events = try parser.parse(path: appEventsPath)
        let view = AppLayer(events: events, scale: 3)
        
        view.frame = CGRect(x: 0,
                            y: 0,
                            width: view.intrinsicContentSize.width,
                            height: view.intrinsicContentSize.height)
        let layer: CALayer = view
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
    
    func test_drawingTestEvents() throws {
        throw XCTSkip("too slow")
        let events = try parser.parse(path: testEventsPath)
        let view = AppLayer(events: events, scale: 3)
        //        view.highlightedEvent = events[100]
        //        view.highlightEvent(at: <#T##CGPoint#>)
        
        view.frame = CGRect(x: 0,
                            y: 0,
                            width: view.intrinsicContentSize.width,
                            height: view.intrinsicContentSize.height)
        let layer: CALayer = view
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
}
