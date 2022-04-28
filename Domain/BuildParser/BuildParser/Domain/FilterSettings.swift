//
//  FilterSettings.swift
//  
//
//  Created by Mikhail Rubanov on 08.04.2022.
//

import Foundation
import XCLogParser

public class FilterSettings {
    public static var shared = FilterSettings()
    
    public init() {}
    
    @Storage(key: "showCached", defaultValue: true)
    public var showCached: Bool
    public var hideCached: Bool {
        !showCached
    }
    
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
