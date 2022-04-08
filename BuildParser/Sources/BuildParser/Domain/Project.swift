//
//  Project.swift
//  
//
//  Created by Mikhail Rubanov on 08.04.2022.
//

import Foundation
import GraphParser

public class Project: Equatable {
    public static func == (lhs: Project, rhs: Project) -> Bool {
        lhs === rhs
    }
    
    public init(events: [Event], relativeBuildStart: CGFloat) {
        self.events = events
        self.relativeBuildStart = relativeBuildStart
    }
    
    public let events: [Event]
    public let relativeBuildStart: CGFloat
    
    public private(set) var cachedDependencies: [Dependency]?
    public func connect(dependencies: [Dependency]) {
        self.cachedDependencies = dependencies
        
        events.connect(by: dependencies)
    }
}
