//
//  BuildStepCounter.swift
//  
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import Foundation
import XCLogParser

public class BuildStepCounter {
    init(buildStep: BuildStep) {
        self.buildStep = buildStep
    }
    
    let buildStep: BuildStep
    
    public func duration(of stepType: DetailStepType) -> TimeInterval {
        buildStep.duration(of: stepType)
    }
}

extension BuildStep {
    func duration(of stepType: DetailStepType) -> TimeInterval {
        guard !subSteps.isEmpty else {
            if self.detailStepType == stepType {
                return duration
            } else {
                return 0
            }
        }
        
        return subSteps.reduce(0, { result, step in
            result + step.duration(of: stepType)
        })
    }
}

