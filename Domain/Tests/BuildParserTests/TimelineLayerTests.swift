//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 06.01.2022.
//

import XCTest
@testable import BuildParser
import SnapshotTesting

final class TimelineLayerTests: XCTestCase {
    let record = false
    
    func test2Min() {
        let layer = layer(minutes: 2)
        
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
    
    func test10Min() {
        let layer = layer(minutes: 10)
        
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
    
    func test20Min() {
        let layer = layer(minutes: 20)
        
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
    
    func test60Min() {
        let layer = layer(minutes: 60)
        
        assertSnapshot(matching: layer,
                       as: .image,
                       record: record)
    }
    
    private func layer(minutes: TimeInterval) -> TimelineLayer {
        let layer = TimelineLayer(eventsDuration: 60*minutes, scale: 1)
        
        layer.frame = .init(x: 0,
                            y: 0,
                            width: 300,
                            height: 120)
        return layer
    }
}
