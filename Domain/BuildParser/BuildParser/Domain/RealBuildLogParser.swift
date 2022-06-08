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
    public func makeCounter() -> BuildStepCounter? {
        if buildStep != nil {
            return BuildStepCounter(buildStep: buildStep)
        } else {
            return nil
        }
    }
    
    public var title: String {
        buildStep.title
    }
    

    public private(set) var depsPath: URL?
    
    public func parse(projectReference: ProjectReference, filter: FilterSettings) throws -> Project {
        try parse(
            logURL: projectReference.currentActivityLog,
            rootURL: projectReference.rootPath,
            filter: filter)
    }
    
    public func parse(logURL: URL, rootURL: URL, filter: FilterSettings) throws -> Project {
        os_log("start parsing")
        var date = Date()
        
        // 1. Read file
        let activityLog = try activityLogParser.parseActivityLogInURL(logURL)
        
        depsPath = DepsPathExtraction(rootURL: rootURL).depedenciesPath(activityLog: activityLog)
        
        var diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("read activity log, \(diff)")
        }
        date = Date()
        
        // 2. Parse to build steps
        buildStep = try buildParser.parse(activityLog: activityLog)
        
        diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("parse logs, \(diff)")
        }
        date = Date()
        
        // 3. Convert to Events
        let events = BuildStepConverter().convertToEvents(
            steps: buildStep.subSteps,
            buildStart: buildStep.startDate,
            filter: filter)
        
        diff = Date().timeIntervalSince(date)
        if #available(macOS 11.0, *) {
            os_log("convert events, \(diff)")
        }
        
        return Project(events: events,
                       relativeBuildStart: 0
                        
//                        relativeDuration(events: events, buildStart: buildStep.startDate)
        )
    }
    
//    private func relativeDuration(events: [Event], buildStart: Date) -> CGFloat {
//        guard let duration = events.duration() else {
//            return 0
//        }
//        
//        let earliestDate = events.start()
//        let buildStart = buildStep.startDate
//        
//        let relativeStart = buildStart.timeIntervalSince(earliestDate) / duration
//        return relativeStart
//    }
    
    public func update(with filter: FilterSettings) -> [Event] {
        BuildStepConverter().convertToEvents(steps: buildStep.subSteps,
                                             buildStart: buildStep.startDate,
                                             filter: filter)
    }
    
    public func step(for event: Event) -> BuildStep? {
        let step = buildStep.subSteps.first { step in
            step.title.hasSuffix(event.taskName)
        }
        
        return step
    }
    
    let dateFormatter = DateFormatter.iso8601Full_Z
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: count)
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

enum ParsingError: Error {
    case noEventsFound
}

extension ParsingError: CustomNSError {
    var localizedDescription: String {
        switch self {
        case .noEventsFound: return NSLocalizedString("No compilation data found", comment: "")
        }
    }
}
