import Foundation

public struct Event {
    public init(taskName: String,
                startDate: Date,
                endDate: Date) {
        self.taskName = taskName
        self.startDate = startDate
        self.endDate = endDate
    }
    
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
    
    func concurency(at timeFromStart: TimeInterval) -> Int {
        return events(at: timeFromStart).count
    }
    
    private func events(at timeFromStart: TimeInterval) -> [Event] {
        let checkDate = Date(timeInterval: timeFromStart, since: start())
        
        return self.filter { $0.hit(time: checkDate) }
    }
}
extension Event {
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    func hit(time: Date) -> Bool {
        (startDate...endDate).contains(time)
    }
}
