//
//  DetailsStatePresenter.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 13.02.2022.
//

import Foundation
import BuildParser
import GraphParser

//protocol DetailStateUIProtocol {
//
//}

class DetailsStatePresenter {
    //    weak var ui: DetailStateUIProtocol?
    
    let parser = RealBuildLogParser()
    
    func loadAndInsert(
        project: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ events: [Event],
                            _ deps: [Dependency],
                            _ title: String,
                            _ project: ProjectReference) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        print("will read \(project.activityLogURL), depsURL \(String(describing: project.depsURL))")
        
        do {
            let events = try parser.parse(
                logURL: project.currentActivityLog,
                filter: filter)
            
            guard events.count > 0 else {
                // TODO: depends on compilationOnly flag
                didFail(NSLocalizedString("No compilation data found", comment: ""))
                return
            }
            
            let dependencies = connectWithDependencies(events: events,
                                                       depsURL: project.depsURL)
            
            didLoad(events, dependencies, self.parser.title, project)
        } catch let error {
            didFail(error.localizedDescription)
        }
    }
    
    func updateWithFilter(
        project: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ events: [Event], _ deps: [Dependency], _ title: String) -> Void
    ) {
        let events = parser.update(with: filter)
        
        let dependencies = connectWithDependencies(events: events, depsURL: project.depsURL)
        
        didLoad(events, dependencies, parser.title)
    }
    
    private func connectWithDependencies(events: [Event], depsURL: URL?) -> [Dependency] {
        var dependencies = [Dependency]()
        
        if let depsURL = depsURL {
            if let depsContent = try? String(contentsOf: depsURL) {
                dependencies = DependencyParser().parseFile(depsContent)
            } else {
                // TODO: Log
            }
        }
        
        events.connect(by: dependencies)
        
        return dependencies
    }
}
