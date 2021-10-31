//
//  RealBuildLogParser.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import XCLogParser
import Interface
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
    
    public func parse(logURL: URL) throws -> [Event] {
        let activityLog = try activityLogParser.parseActivityLogInURL(
            logURL,
            redacted: false,
            withoutBuildSpecificInformation: false)
        
        buildSteps = try buildParser.parse(activityLog: activityLog)
       
        let events = convertToEvents(buildSteps: buildSteps)
        return events
    }
    
    public func description(event: Event) -> String {
        let step = buildSteps.subSteps.first { step in
            step.title.hasSuffix(event.taskName)
        }!
        
        return step.description
    }
    
    private func convertToEvents(
        buildSteps: BuildStep
    ) -> [Event] {
        let dateFormatter = DateFormatter.iso8601Full
        let events = buildSteps.subSteps
            .compactMap { step -> Event? in
                let substeps = step
                    .subSteps
                    .filter { $0.isCompilationStep() }
                
                guard let startDate = substeps.first?.startDate,
                      let lastDate = substeps.last?.endDate else {
                          return nil
                      }
                
                return Event(
                    taskName: step.title.without_Build_target,
                    startDate: dateFormatter.date(from: startDate)!,
                    endDate: dateFormatter.date(from: lastDate)!,
                    steps: substeps.map { substep in
                        Event(taskName: substep.title,
                              startDate: dateFormatter.date(from: substep.startDate)!,
                              endDate: dateFormatter.date(from: substep.endDate)!,
                              steps: [])
                    }
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
    var description: String {
        var description = "\(duration)\t\(title)\n\n"
        
        for substep in subSteps {
            description.append(String(format: "\t%0.2f\t\(substep.title)\n", substep.duration))
        }
        
        return description
    }
    
    func output() {
        print(description)
    }
}
