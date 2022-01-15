//
//  RealBuildLogParser.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import XCLogParser
import Foundation

public class RealBuildLogParser {
   
    public init() {}
    
    let activityLogParser = ActivityParser()
    let buildParser = ParserBuildSteps(
        machineName: nil,
        omitWarningsDetails: true,
        omitNotesDetails: true)
    
    var buildSteps: BuildStep!
    public var title: String {
        buildSteps.title
    }
    
    public func parse(logURL: URL, compilationOnly: Bool) throws -> [Event] {
        let activityLog = try activityLogParser.parseActivityLogInURL(
            logURL,
            redacted: false, // Parameter is not important, code was comment out
            withoutBuildSpecificInformation: false) // Parameter is not important, code was comment out
        
        buildSteps = try buildParser.parse(activityLog: activityLog)
       
        let events = convertToEvents(buildSteps: buildSteps, compilationOnly: compilationOnly)
        return events
    }
    
    public func step(for event: Event) -> BuildStep? {
        let step = buildSteps.subSteps.first { step in
            step.title.hasSuffix(event.taskName)
        }
        
        return step
    }
    
    func convertToEvents(
        buildSteps: BuildStep,
        compilationOnly: Bool
    ) -> [Event] {
        let dateFormatter = DateFormatter.iso8601Full_Z
        let events = buildSteps.subSteps
            .compactMap { step -> Event? in
                var substeps = step.subSteps
                
                if compilationOnly {
                    substeps = substeps.filter { $0.isCompilationStep() }
                }
                
                guard let startDate = substeps.first?.startDate,
                      let lastDate = substeps.last?.endDate
                else {
                    return nil // Empty array
                }
                
                return Event(
                    taskName: step.title.without_Build_target,
                    startDate: dateFormatter.date(from: startDate)!,
                    endDate: dateFormatter.date(from: lastDate)!,
                    steps: convertToEvents(subSteps: substeps)
                )
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
        let dateFormatter = DateFormatter.iso8601Full_Z
        let events = subSteps
            .map { step -> Event in
                return Event(
                    taskName: step.title.without_Build_target,
                    startDate: dateFormatter.date(from: step.startDate)!,
                    endDate: dateFormatter.date(from: step.endDate)!,
                    steps: convertToEvents(subSteps: step.subSteps)
                )
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
