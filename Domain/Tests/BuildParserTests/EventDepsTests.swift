//
//  EventDepsTests.swift
//  
//
//  Created by Mikhail Rubanov on 05.11.2021.
//

import Foundation
import XCTest
import CustomDump

@testable import BuildParser
import GraphParser

class EventDepsTests: XCTestCase {
    
    let target1 = Target(target: "1", project: "1")
    let target2 = Target(target: "2", project: "2")
    let target3 = Target(target: "3", project: "3")
    
    var events: [Event]!
    
    override func setUp() {
        super.setUp()
        
        events = [
            .testMake(taskName: "1"),
            .testMake(taskName: "2"),
            .testMake(taskName: "3")
        ]
    }
    
    func test_2contains1() {
        let deps = [
            Dependency(target: target1, dependencies: []),
            Dependency(target: target2, dependencies: [target1])
        ]
        
        events.connect(by: deps)
        
        XCTAssertEqual(events[0].parents, [])
        XCTAssertEqual(events[1].parents, [events[0]])
    }
    
    
    func test_thirdContainsFirstTwo() {
        let deps = [
            Dependency(target: target1, dependencies: []),
            Dependency(target: target2, dependencies: []),
            Dependency(target: target3, dependencies: [
                target1,
                target2
            ])
        ]

        events.connect(by: deps)

        XCTAssertEqual(events[0].parents, [])
        XCTAssertEqual(events[1].parents, [])
        XCTAssertNoDifference(events[2].parents, [events[0], events[1]])
        
        XCTAssertFalse(events[0].parentsContains("1"))
        
        XCTAssertTrue(events[2].parentsContains("1"))
        XCTAssertTrue(events[2].parentsContains("2"))
        
        // TODO: Test longer chain
    }
    
    func test_twoDependenciesInChain() {
        let deps = [
            Dependency(target: target1, dependencies: []),
            Dependency(target: target2, dependencies: [target1]),
            Dependency(target: target3, dependencies: [
                target2
            ])
        ]
        
        events.connect(by: deps)
        
        XCTAssertEqual(events[0].parents, [])
        XCTAssertEqual(events[1].parents, [events[0]])
        XCTAssertNoDifference(events[2].parents, [events[1]])
        
        XCTAssertFalse(events[0].parentsContains("1"))
        XCTAssertTrue(events[1].parentsContains("1"))
        XCTAssertTrue(events[2].parentsContains("1"))
        XCTAssertTrue(events[2].parentsContains("2"))
    }
    
    func test_dependenciesLoop() {
        let deps = [
            Dependency(target: target1, dependencies: [target2]),
            Dependency(target: target2, dependencies: [target1]),
        ]
        
        events.connect(by: deps)
        
        XCTAssertTrue(events[0].parentsContains("2"))
        XCTAssertTrue(events[1].parentsContains("1"))
    }
}

extension Event {
    static func testMake(
        taskName: String = "",
        startDate: Date = Date(),
        duration: TimeInterval = 0,
        fetchedFromCache: Bool = false,
        steps: [Event] = []
    ) -> Event {
        Event(taskName: taskName, startDate: startDate, duration: duration, fetchedFromCache: fetchedFromCache, steps: steps)
    }
}
