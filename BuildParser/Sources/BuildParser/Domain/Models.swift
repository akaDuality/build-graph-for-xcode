import Foundation
import SwiftUI

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
    
    func concurrency(at timeFromStart: TimeInterval) -> Int {
        return events(at: timeFromStart).count
    }
    
    private func events(at timeFromStart: TimeInterval) -> [Event] {
        let checkDate = Date(timeInterval: timeFromStart, since: start())
        
        return self.filter { $0.hit(time: checkDate) }
    }
    
    func concurrency(at date: Date) -> Int {
        return events(at: date).count
    }
    
    private func events(at date: Date) -> [Event] {
        return self.filter { $0.hit(time: date) }
    }
    
    func periods(concurrency: Int) -> [Date] {
        let allDates = map(\.startDate) + map(\.endDate)
        return allDates.filter { date in
            let time = date.timeIntervalSince(start()) + 0.01
            return self.concurrency(at: time) == concurrency
        }
        
        // TODO: Potential duplication with allPeriods()
    }
    
    func allPeriods() -> [Period] {
        let set: Set<Date> = Set(map(\.startDate) + map(\.endDate))
        let allDates = set.sorted()
        
        var periods = [Period]()
        for index in 0..<allDates.count - 1 {
            let start = allDates[index]
            let end = allDates[index + 1]
            let interval = end.timeIntervalSince(start)
            
            let middleTime = start.addingTimeInterval(interval / 2)
            let concurrency = concurrency(at: middleTime.timeIntervalSince(self.start()))
            let period = Period(concurrency: concurrency, start: start, end: end)
            periods.append(period)
        }
        
        return periods
    }
    
    func isBlocker(_ event: Event) -> Bool {
        let concBefore = concurrency(at: event.endDate.addingTimeInterval(-0.01))
        let concAfter  = concurrency(at: event.endDate.addingTimeInterval(0.01))
        return concAfter > concBefore
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

struct Period {
    let concurrency: Int
    let start: Date
    let end: Date
}

func relativeStart(absoluteStart: Date, start: Date, duration: TimeInterval) -> CGFloat {
    CGFloat(start.timeIntervalSince(absoluteStart) / duration)
}

func relativeDuration(start: Date, end: Date, duration: TimeInterval) -> CGFloat {
    CGFloat(end.timeIntervalSince(start) / duration)
}
