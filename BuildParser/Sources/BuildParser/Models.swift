import Foundation

struct Event {
    let taskName: String
    let startDate: Date
    let endDate: Date
    
    var type: EventType {
        if taskName.hasSuffix(helpersSuffix) {
            return .helpers
        } else if taskName.hasSuffix(testsSuffix) {
            return .tests
        } else {
            return .framework
        }
    }
    enum EventType {
        case framework
        case helpers
        case tests
    }
    
    private let helpersSuffix = "TestHelpers"
    private let testsSuffix = "TestHelpers-Unit-Tests"
    
    var domain: String {
        if taskName.hasSuffix(helpersSuffix) {
            return String(taskName.dropLast(helpersSuffix.count))
        } else if taskName.hasSuffix(testsSuffix) {
            return String(taskName.dropLast(testsSuffix.count))
        } else {
            return taskName
        }
    }
}

extension Array where Element == Event {
    func filter(_ suffix: String) -> [Element] {
        filter { event in
            event.taskName.hasSuffix(suffix)
        }
    }
    
    func contains(_ event: Element) -> Bool {
        self.contains { innerEvent in
            innerEvent.taskName == event.taskName
        }
    }
    
    func duration() -> TimeInterval {
        last!.endDate.timeIntervalSince(first!.startDate)
    }
    
    func start() -> Date {
        first!.startDate
    }
}
extension Event {
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

struct EventsDTO: Decodable {
    let events: [EventDTO]
}

struct EventDTO: Decodable {
    let date: Date
    let taskName: String
    let event: EventType
}

enum EventType: String, Decodable {
    case start
    case end
}
