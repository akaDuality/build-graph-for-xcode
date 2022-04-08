//
//  DetailsStatePresenter.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 13.02.2022.
//

import Foundation
import BuildParser
import GraphParser
import os

//protocol DetailStateUIProtocol {
//
//}

class DetailsStatePresenter {
    //    weak var ui: DetailStateUIProtocol?
    
    let parser = RealBuildLogParser()
    
    func loadAndInsert(
        projectReference: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ projectReference: Project,
                            _ title: String,
                            _ projectReference: ProjectReference) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        os_log("loadAndInsert")
        
        Task {
            os_log("will read \(projectReference.activityLogURL), depsURL \(String(describing: projectReference.depsURL))")
            
            do {
                // TODO: how this try is handled?
                let project = try await project(currentActivityLog: projectReference.currentActivityLog, filter: filter)
                let dependencies = await dependencies(depsURL: projectReference.depsURL)
                
                project.connect(dependencies: dependencies)
                
                guard project.events.count > 0 else {
                    // TODO: depends on compilationOnly flag
                    didFail(ParsingError.noEventsFound.localizedDescription)
                    return
                }
                
                didLoad(project, self.parser.title, projectReference)
            } catch let error {
                didFail(error.localizedDescription)
            }
        }
    }
    
    func updateWithFilter(
        oldProject: Project,
        projectReference: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ project: Project, _ title: String) -> Void
    ) {
        // TODO: Rework to project
        let events = parser.update(with: filter)
        
        if let dependencies = oldProject.cachedDependencies {
            events.connect(by: dependencies)
        }
        
        // TODO: Create in another place
        let project = Project(events: events, relativeBuildStart: 0)
        
        didLoad(project, parser.title)
    }
    
    private func project(currentActivityLog: URL, filter: FilterSettings) async throws -> Project {
        try parser.parse(
            logURL: currentActivityLog,
            filter: filter)
    }
    
    private func dependencies(depsURL: URL?) async -> [Dependency] {
        var dependencies = [Dependency]()
        
        if let depsURL = depsURL {
            if let depsContent = try? String(contentsOf: depsURL) {
                dependencies = DependencyParser().parseFile(depsContent)
            } else {
                // TODO: Log
            }
        }
        return dependencies
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
