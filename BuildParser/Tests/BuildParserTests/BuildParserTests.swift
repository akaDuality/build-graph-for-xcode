import XCTest
@testable import BuildParser

import SnapshotTesting

let appEventsPath = Bundle.module.url(forResource: "AppEvents", withExtension: "json")!
let testEventsPath = Bundle.module.url(forResource: "TestEvents", withExtension: "json")!

final class BuildParserTests: XCTestCase {
    
    let parser = BuildLogParser()
    
    func testParsing() throws {
        let buildLog = try parser.buildLog(path: testEventsPath)
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
        XCTAssertEqual(events.count, 86)
        
        Analyzer().analyze(events: events)
        
        let concurency = events.concurency(at: 0)
        XCTAssertEqual(concurency, 18)
        
        let concurency2 = events.concurency(at: 240)
        XCTAssertEqual(concurency2, 1)
    }
    
    func testParsingToCombinedEvents_testEvents() throws {
        let events = try parser.parse(path: testEventsPath)
        XCTAssertEqual(events.count, 196)
        
        Analyzer().analyze(events: events)
    }
}

final class GraphTests: XCTestCase {
    
    let parser = BuildLogParser()
    
    func test_drawingAppEvents() throws {
        let events = try parser.parse(path: appEventsPath)
        let view = Graph(events: events, scale: 3)
        
        view.frame = .init(x: 0,
                           y: 0,
                           width: view.intrinsicContentSize.width,
                           height: view.intrinsicContentSize.height)
        let layer: CALayer = view
        assertSnapshot(matching: layer,
                       as: .image,
                       record: true)
    }
    
    func test_drawingTestEvents() throws {
        let events = try parser.parse(path: testEventsPath)
        let view = Graph(events: events, scale: 3)
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
