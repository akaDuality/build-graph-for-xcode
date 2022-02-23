//
//  RealBuildLogParser.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import XCLogParser
import Foundation

public class FilterSettings {
    public static var shared = FilterSettings()
    
    public init() {}
    
    public var showCached: Bool = true
    
    public var allowedTypes: [DetailStepType] = DetailStepType.compilationSteps
    
    public func add(stepType: DetailStepType) {
        allowedTypes.append(stepType)
    }
    
    public func remove(stepType: DetailStepType) {
        guard let indexToRemove = allowedTypes.firstIndex(of: stepType) else {
            return
        }
        allowedTypes.remove(at: indexToRemove)
    }
    
    public func enableAll() {
        allowedTypes = DetailStepType.allCases
    }
}

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
    
    public func parse(logURL: URL, filter: FilterSettings) throws -> [Event] {
        let activityLog = try activityLogParser.parseActivityLogInURL(
            logURL,
            redacted: false, // Parameter is not important, code was comment out
            withoutBuildSpecificInformation: false) // Parameter is not important, code was comment out
        
        buildStep = try buildParser.parse(activityLog: activityLog)
       
        let events = convertToEvents(buildStep: buildStep, filter: filter)
        return events
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
    
    func convertToEvents(
        buildStep: BuildStep,
        filter: FilterSettings
    ) -> [Event] {
        let dateFormatter = DateFormatter.iso8601Full_Z
        let events = buildStep.subSteps
            .compactMap { step -> Event? in
                var substeps = step.subSteps
                
                // TODO: Speedup if all or none settings are enabled
                substeps = substeps.filter { substep in
                    filter.allowedTypes.contains(substep.detailStepType)
                }
                
                guard let startDate = substeps.first?.startDate,
                      let lastDate = substeps.last?.endDate
                else {
                    return nil // Empty array
                }
                
                if !filter.showCached && step.fetchedFromCache {
                    return nil
                }
                
                return Event(
                    taskName: step.title.without_Build_target,
                    startDate: dateFormatter.date(from: startDate)!,
                    endDate: dateFormatter.date(from: lastDate)!,
                    fetchedFromCache: step.fetchedFromCache,
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
                    fetchedFromCache: step.fetchedFromCache,
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
