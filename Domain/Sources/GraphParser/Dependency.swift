//
//  Dependency.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import Foundation

public struct Dependency: Equatable {
    public init(
        target: Target,
        dependencies: [Target]
    ) {
        self.target = target
        self.dependencies = dependencies
    }
    
    public let target: Target
    public let dependencies: [Target]
}

public struct Target: Equatable {
    public init(
        target: String,
        project: String
    ) {
        self.target = target
        self.project = project
    }
    
    public let target: String
    public let project: String
}

public enum DependencyType: Equatable {
    //    case explicit
    case implicit
}
