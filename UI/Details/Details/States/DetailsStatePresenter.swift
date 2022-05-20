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

public class DetailsStatePresenter {
    //    weak var ui: DetailStateUIProtocol?
    
    public let parser = RealBuildLogParser()
    
    func loadAndInsert(
        projectReference: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ projectReference: Project,
                            _ title: String,
                            _ projectReference: ProjectReference) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        os_log("will read \(projectReference.activityLogURL), depsURL \(String(describing: projectReference.depsURL))")
        
        do {
            let project = try parser.parse(
                logURL: projectReference.currentActivityLog,
                rootURL: projectReference.rootPath,
                filter: filter)
            
            if let depsPath = parser.depsPath,
               let dependencies = dependencies(depsURL: depsPath) {
                project.connect(dependencies: dependencies)
            }
            
            didLoad(project, self.parser.title, projectReference)
        } catch let error {
            didFail(error.localizedDescription)
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
    
    private func dependencies(depsURL: URL) -> [Dependency]? {
        guard let depsContent = try? String(contentsOf: depsURL) else {
            return nil
        }
        
        return DependencyParser().parseFile(depsContent)
    }
}
