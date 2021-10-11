import XCTest
@testable import BuildParser

import SnapshotTesting

final class BuildParserTests: XCTestCase {
    
    let appEventsPath = Bundle.module.url(forResource: "AppEvents", withExtension: "json")!
    let testEventsPath = Bundle.module.url(forResource: "TestEvents", withExtension: "json")!
    let parser = BuildLogParser()
    
    func testParsing() throws {
        let buildLog = try parser.buildLog(path: appEventsPath)
        XCTAssertEqual(buildLog.events.count, 392)
        
        let firstEvent = buildLog.events[0]
//        XCTAssertEqual(firstEvent.date, "2021-10-08T11:59:59.1633676399")
        XCTAssertEqual(firstEvent.taskName, "Crypto")
        XCTAssertEqual(firstEvent.event, .start)
        
        let secondEvent = buildLog.events[1]
//        XCTAssertEqual(secondEvent.date, "2021-10-08T12:00:00.1633676400")
        XCTAssertEqual(secondEvent.taskName, "Crypto")
        XCTAssertEqual(secondEvent.event, .end)
    }
    
    func testParsingToCombinedEvents_appEvents() throws {
        let events = try parser.parse(path: appEventsPath)
        XCTAssertEqual(events.count, 392 / 2)
        
        Analyzer().analyze(events: events)
    }
    
    func test_drawingTestEvents() throws {
        let events = try parser.parse(path: testEventsPath)
        let view = Graph(events: events)
        view.highlightedEvent = events[100]
            
        view.frame = .init(x: 0,
                           y: 0,
                           width: view.intrinsicContentSize.width,
                           height: view.intrinsicContentSize.height)
        let layer: CALayer = view
        assertSnapshot(matching: layer,
                       as: .image,
                       record: true)
    }
}


