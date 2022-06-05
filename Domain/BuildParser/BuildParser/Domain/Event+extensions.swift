//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import Foundation
import GraphParser

let helpersSuffix = "TestHelpers"
let testsSuffix = "TestHelpers-Unit-Tests"

// TODO: Remove global access
private let eventDescriptionFormatter  = DurationFormatter()

extension Event {
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
    
    var domain: String {
        if taskName.hasSuffix(helpersSuffix) {
            return String(taskName.dropLast(helpersSuffix.count))
        } else if taskName.hasSuffix(testsSuffix) {
            return String(taskName.dropLast(testsSuffix.count))
        } else {
            return taskName
        }
    }
    
    public var description: String {
        "\(taskName), \(eventDescriptionFormatter.string(from: duration))"
    }
    
//    public var dateDescription: String {
//        String(format: "%0.2f, \(taskName)", duration)
//    }
//
//    public func output() {
//        print("\n\(taskName)")
//        for step in steps {
//            print(step.dateDescription)
//        }
//    }
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
    
    public func duration() -> TimeInterval? {
        guard count > 0 else {
            return nil
        }
        
        if count == 1 {
            return self[0].duration
        } else {
            return last!.endDate.timeIntervalSince(first!.startDate)
        }
    }
    
    func start() -> Date {
        first!.startDate
    }
    
    private func date(from timeFromStart: TimeInterval) -> Date {
        Date(timeInterval: timeFromStart, since: start())
    }
    
    func concurrency(at timeFromStart: TimeInterval) -> Int {
        return concurrency(at: date(from: timeFromStart))
    }
    
    private func events(at timeFromStart: TimeInterval) -> [Event] {
        return events(at: date(from: timeFromStart))
    }
    
    func concurrency(at date: Date) -> Int {
        return events(at: date).count
    }
    
    func removeGap(period: Period) {
        let duration = period.duration // cache for faster calculation
        
        for event in self {
            if event.startDate > period.start {
                event.startDate = event.startDate.addingTimeInterval(-duration)
            }
            
            event.steps.removeGap(period: period) // Compile assets can recompile even in frameworks that have been compiled already
        }
    }
    
    private func events(at time: Date) -> [Event] {
        return filter { event in
            if event.steps.count > 0 {
                return event.stepsHit(time: time)
            } else {
                return event.hit(time: time)
            }
        }
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
        let set: Set<Date> = map(\.dates)
            .reduce(Set()) { result, dates in
            result.union(dates)
        }
        
        guard set.count > 0 else {
            return []
        }
        
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
    
    public func connect(by deps: [Dependency]) {
        for dep in deps {
            for tagret in dep.dependencies {
                let child = event(with: dep.target.target)
                let parent = event(with: tagret.target)
                
                guard let parent = parent,
                      let child = child
                else { continue }
                
                // TODO: Can be removed as I understand
                guard child.parents.first?.taskName != parent.taskName else {
                    // TODO: Remove on parsing
                    print("cycle dependency \(parent.taskName), skip")
                    continue
                }
                
                guard child.parents.first?.taskName != parent.taskName else {
                    // TODO: Remove on parsing
                    print("cycle dependency \(parent.taskName), skip")
                    continue
                }
                
                child.parents.append(parent)
            }
        }
    }
    
    func event(with name: String) -> Event? {
        first { event in
            event.taskName == name
        }
    }
}

extension Event {
    
    func hit(time: Date) -> Bool {
        (startDate...endDate).contains(time)
    }
    
    func stepsHit(time: Date) -> Bool {
        steps.first { step in
            step.hit(time: time)
        } != nil
    }
    
    var dates: Set<Date> {
        Set(steps.map(\.startDate) + steps.map(\.endDate))
    }
    
    func parentsContains(_ domain: String) -> Bool {
        for parent in parents {
            if parent.taskName == domain {
                return true
            }
            
            if parent.parentsContains(domain) {
                return true
            }
        }
        
        return false
    }
    
    func isBlocked(by event: Event) -> Bool {
        let interval = startDate.timeIntervalSince(event.endDate)
        
        return (0...1).contains(interval)
    }
}

struct Period {
    let concurrency: Int
    let start: Date
    let end: Date
    
    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }
}

func relativeStart(absoluteStart: Date, start: Date, duration: TimeInterval) -> CGFloat {
    CGFloat(start.timeIntervalSince(absoluteStart) / duration)
}

func relativeDuration(start: Date, end: Date, duration: TimeInterval) -> CGFloat {
    CGFloat(end.timeIntervalSince(start) / duration)
}
