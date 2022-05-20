//
//  BuildStepConverter.swift
//  BuildParser
//
//  Created by Mikhail Rubanov on 20.05.2022.
//

import Foundation
import XCLogParser

class BuildStepConverter {
    func convertToEvents(
        buildStep: BuildStep,
        filter: FilterSettings
    ) -> [Event] {
        let buildStart = buildStep.startDate
        
        let events: [Event] = buildStep.subSteps
            .parallelCompactMap { step -> Event? in
                if filter.cacheVisibility == .currentBuild {
                    let buildEarlierThanCurrentBuild = step.beforeBuild(buildDate: buildStart)
                    if step.fetchedFromCache
                        || buildEarlierThanCurrentBuild {
                        return nil
                    }
                }
                
                var substeps = step.subSteps
                
                // TODO: Speedup if all or none settings are enabled
                substeps = self.filter(substeps: substeps, filter: filter, buildStart: buildStart)
                
                guard
                    let startDate = substeps.first?.startDate,
                    let endDate = substeps.last?.startDate
                else {
                    return nil // Empty array
                }
                
                let duration = endDate.timeIntervalSince(startDate)
                guard duration > 0 else {
                    return nil
                }
                
                return self.event(from: step,
                                  startDate: startDate,
                                  duration: duration,
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
    
    private func filter(
        substeps: [BuildStep],
        filter: FilterSettings,
        buildStart: Date
    ) -> [BuildStep] {
        var substeps = substeps.filter { substep in
            filter.allowedTypes.contains(substep.detailStepType)
        }
        
        substeps = substeps.filter({ substep in
            switch filter.cacheVisibility {
            case .all:
                return true
            case .cached:
                return substep.startDate < buildStart
            case .currentBuild:
                return substep.startDate > buildStart
            }
        })
        
        return substeps
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
    
    // TODO: Remove
    private func last(
        substeps: [BuildStep],
        cacheVisibility: FilterSettings.CacheVisibility,
        buildStart: Date
    ) -> Date? {
        switch cacheVisibility {
        case .all:
            return substeps.last?.endDate
        case .cached:
            return substeps.filter({ step in
                step.startDate < buildStart
            }).last?.endDate
        case .currentBuild:
            return substeps.filter({ step in
                step.startDate > buildStart
            }).last?.endDate
        }
    }
}
