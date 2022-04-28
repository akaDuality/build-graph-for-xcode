//
//  RealBuildLogParser.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import XCLogParser
import Foundation
import os

extension DetailStepType {
    static var compilationSteps: [Self] {
        Self.allCases
            .filter { $0.isCompilationStep() }
    }
}

public class RealBuildLogParser {
   
    public init() {}
    
    let activityLogParser = ActivityParser()
    let buildParser = ParserBuildSteps(
        machineName: nil,
        omitWarningsDetails: true,
        omitNotesDetails: true)
    
    var buildStep: BuildStep!
    public func makeCounter() -> BuildStepCounter {
        BuildStepCounter(buildStep: buildStep)
    }
    
    public var title: String {
        buildStep.title
    }
    
    var progress = Progress(totalUnitCount: 3)
    public private(set) var depsPath: URL?
    public func parse(logURL: URL, rootURL: URL, filter: FilterSettings) throws -> Project {
        progress = Progress(totalUnitCount: 3)
        os_log("start parsing")
        var date = Date()
        
        let activityLog = try activityLogParser.parseActivityLogInURL(logURL)
        
        depsPath = DepsPathExtraction(rootURL: rootURL).depedenciesPath(activityLog: activityLog)
        
        var diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("read activity log, \(diff)")
        }
        date = Date()
        
        progress.completedUnitCount = 1
        
        buildStep = try buildParser.parse(activityLog: activityLog)
        progress.completedUnitCount = 2
        diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("parse logs, \(diff)")
        }
        date = Date()
        
        let events = convertToEvents(buildStep: buildStep, filter: filter)
        progress.completedUnitCount = 3
        diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("convert events, \(diff)")
        }
        
        return Project(events: events,
                       relativeBuildStart: relativeDuration(events: events, buildStart: buildStep.startDate))
    }
    
    private func relativeDuration(events: [Event], buildStart: Date) -> CGFloat {
        let duration = events.duration()
        guard duration > 0 else {
            return 0
        }
        
        let earliestDate = events.start()
        let buildStart = buildStep.startDate
        
        let relativeStart = buildStart.timeIntervalSince(earliestDate) / duration
        return relativeStart
    }
    
    public func update(with filter: FilterSettings) -> [Event] {
        convertToEvents(buildStep: buildStep, filter: filter)
    }
    
    public func step(for event: Event) -> BuildStep? {
        let step = buildStep.subSteps.first { step in
            step.title.hasSuffix(event.taskName)
        }
        
        return step
    }
    
    let dateFormatter = DateFormatter.iso8601Full_Z
    
    func convertToEvents(
        buildStep: BuildStep,
        filter: FilterSettings
    ) -> [Event] {
        
        let events: [Event] = buildStep.subSteps
            .parallelCompactMap { step -> Event? in
                var substeps = step.subSteps
                
                // TODO: Speedup if all or none settings are enabled
                substeps = substeps.filter { substep in
                    filter.allowedTypes.contains(substep.detailStepType)
                }
                
                if !filter.showCached {
                    let buildEarlierThanCurrentBuild = step.beforeBuild(buildDate: buildStep.startDate)
                    if step.fetchedFromCache
                        || buildEarlierThanCurrentBuild {
                        return nil
                    }
                }
                
                guard
                    let startDate = substeps.first?.startDate,
                    let endDate = substeps.last?.endDate
                else {
                    return nil // Empty array
                }
                
                return self.event(from: step,
                                  startDate: startDate,
                                  duration: endDate.timeIntervalSince(startDate),
                                  substeps: substeps)
            }
            .sorted { lhsEvent, rhsEvent in
                if lhsEvent.startDate == rhsEvent.startDate {
                    return lhsEvent.taskName < rhsEvent.taskName
                } else {
                    return lhsEvent.startDate < rhsEvent.startDate
                }
            }
        
        return events
    }
    
    public func convertToEvents(
        subSteps: [BuildStep]
    ) -> [Event] {
        let events = subSteps
            .map { step in
                event(from:step, startDate: step.startDate, duration: step.duration, substeps: step.subSteps)
            }
            .sorted { lhsEvent, rhsEvent in
                if lhsEvent.startDate == rhsEvent.startDate {
                    return lhsEvent.taskName < rhsEvent.taskName
                } else {
                    return lhsEvent.startDate < rhsEvent.startDate
                }
            }
        return events
    }
    
    private func event(from step: BuildStep,
                       startDate: Date,
                       duration: TimeInterval,
                       substeps: [BuildStep]) -> Event {
        Event(
            taskName: step.title.without_Build_target,
            startDate: startDate,
            duration: duration,
            fetchedFromCache: step.fetchedFromCache,
            steps: self.convertToEvents(subSteps: substeps)
        )
    }
}

struct DepsPathExtraction {
    let rootURL: URL
    
    func depedenciesPath(activityLog: IDEActivityLog) -> URL? {
        guard let fileName = fileName(from: activityLog) else { return nil }
        
        return rootURL.appendingPathComponent("Build")
            .appendingPathComponent("Intermediates.noindex")
            .appendingPathComponent("XCBuildData")
            .appendingPathComponent(fileName)
    }
    
    func fileName(from activityLog: IDEActivityLog) -> String? {
        guard let section = activityLog.mainSection.subSections
            .first?.subSections.first(where: { subsection in
                subsection.title == "Create build description"
            }) else { return nil }
        
        guard let number = number(from: String(section.text)) else { return nil }
        return "\(number)-targetGraph.txt"
    }

    func number(from description: String) -> String? {
        let patten = "XCBuildData\\/(\\w*)-"
        let regex = try! NSRegularExpression(pattern: patten)
        let matches = regex.matches(in: description, options: .withoutAnchoringBounds,
                                    range: description.fullRange)
        guard let match = matches.last,
              match.numberOfRanges > 1
        else { return nil }

        let rangeInContent = Range(match.range(at: 1),
                                   in: description)!

        let text = description[rangeInContent]
        return String(text)
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: count)
    }
}

extension Collection {
    // Atother implementation https://talk.objc.io/episodes/S01E90-concurrent-map
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)
        
        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }
        
        return res.map({ $0! })
    }
    
    func parallelCompactMap<R>(_ transform: @escaping (Element) -> R?) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)
        
        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            if let result = transform(self[index(startIndex, offsetBy: i)]) {
                lock.lock()
                res[i] = result
                lock.unlock()
            }
        }
            
        return res.compactMap { $0 }
    }
}

extension String {
    // TODO: Add tests
    // 1. "Build target Crypto"
    // 2. "Crypto"
    var without_Build_target: String {
        let prefix = "Build target "
        if self.hasPrefix(prefix) {
            return String(self.suffix(count - prefix.count))
        } else {
            return self
        }
    }
}

extension BuildStep {
    func description(prefixString: String = "") -> String {
        var description = String(format: "%0.2f \(title)\n", duration)
        
        for substep in subSteps {
            if substep.subSteps.count > 0 {
                description.append(substep.description(prefixString: prefixString + "\t"))
            } else {
                description.append(String(format: "\(prefixString)%0.2f\t\(substep.title)\n", substep.duration))
            }
        }
        
        return description
    }
    
    func output() {
        print(description)
    }
}
