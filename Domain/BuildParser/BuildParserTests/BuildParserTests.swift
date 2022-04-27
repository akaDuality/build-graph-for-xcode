import XCTest
@testable import BuildParser
import CustomDump

//var appEventsPath: URL {
//    return Bundle(for: App_BuildParserTests.self)
//        .url(forResource: "AppEvents", withExtension: "json")!
//}
//
//var testEventsPath: URL {
//    return Bundle(for: App_BuildParserTests.self)
//        .url(forResource: "TestEvents", withExtension: "json")!
//}
//
//final class App_BuildParserTests: XCTestCase {
//    
//    let parser = RealBuildLogParser()
//    var events: [Event]!
//   
//    override func setUpWithError() throws {
//        events = try parser.parse(logURL: appEventsPath, filter: .shared)
//    }
//    
//    func testParsing() throws {
//        let buildLog = try parser.buildLog(path: testEventsPath)
//        XCTAssertEqual(buildLog.events.count, 392)
//        
//        let firstEvent = buildLog.events[0]
////        XCTAssertEqual(firstEvent.date, "2021-10-08T11:59:59.1633676399")
//        XCTAssertEqual(firstEvent.taskName, "Crypto")
//        XCTAssertEqual(firstEvent.event, .start)
//        
//        let secondEvent = buildLog.events[1]
////        XCTAssertEqual(secondEvent.date, "2021-10-08T12:00:00.1633676400")
//        XCTAssertEqual(secondEvent.taskName, "Crypto")
//        XCTAssertEqual(secondEvent.event, .end)
//    }
//    
//    func testParsingToCombinedEvents_appEvents() throws {
//        XCTAssertEqual(events.count, 86)
//    }
//    
//    func testConcurency() {
//        let concurency = events.concurrency(at: 0)
//        XCTAssertEqual(concurency, 18)
//        
//        let concurency2 = events.concurrency(at: 240)
//        XCTAssertEqual(concurency2, 1)
//    }
//    
//    func testPeriods() {
//        let periodsWithLessConcurrency = events.periods(concurrency: 1)
//        XCTAssertEqual(periodsWithLessConcurrency.count, 6)
//    }
//    
//    func testAllPeriods() throws {
//        throw XCTSkip("Periods calculates from subtask")
//        let allPeriods = events.allPeriods()
//        XCTAssertEqual(allPeriods.count, 61)
//    }
//}
//
//final class Test_BuildParserTests: XCTestCase {
//    
//    let parser = RealBuildLogParser()
//    var events: [Event]!
//    override func setUpWithError() throws {
//        events = try parser.parse(path: appEventsPath)
//    }
//    
//    func testParsingToCombinedEvents_testEvents() throws {
//        let events = try parser.parse(logURL: testEventsPath, filter: .shared)
//        XCTAssertEqual(events.count, 196)
//        
//        Analyzer().analyze(events: events)
//        // TODO: nothing to check
//    }
//}
