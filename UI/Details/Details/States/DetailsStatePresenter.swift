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

protocol DetailStateUIProtocol: AnyObject {
    var state: DetailsState { get set }
}

public class DetailsStatePresenter {
    unowned var ui: DetailStateUIProtocol!
    
    public var delegate: DetailsDelegate?
    
    public let parser = RealBuildLogParser()
    
    private var currentProject: ProjectReference?
    
    public func openProject(
        projectReference: ProjectReference,
        filter: FilterSettings,
        then completion: @escaping () -> Void
    ) {
        self.currentProject = projectReference

        ui.state = .loading
        delegate?.willLoadProject(project: projectReference)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            loadAndInsert(
                projectReference: projectReference,
                filter: filter,
                didLoad: { project, title, projectReference in
                    DispatchQueue.main.async {
                        if project.events.isEmpty {
                            self.ui.state = .noEvents(project)
                        } else {
                            self.ui.state = .data(project: project, title: title, projectReference: projectReference)
                        }
    
                        self.delegate?.didLoadProject(
                            project: project,
                            projectReference: projectReference)
                        completion()
                    }
                },
                didFail: { message in
                    DispatchQueue.main.async {
                        // TODO: Sepatate to another state and pass message
                        self.ui.state = .cantRead(projectReference: projectReference)
                        self.delegate?.didFailLoadProject()
                        completion()
                    }
                }
            )
        }
    }
    
    public func updateFilterForCurrentProject(project: Project, filter: FilterSettings) {
        guard let projectReference = currentProject else {
            return
        }
        
        self.ui.state = .loading
        delegate?.willLoadProject(project: projectReference)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            updateWithFilter(
                oldProject: project,
                projectReference: projectReference,
                filter: filter
            ) { project, title in
                
                DispatchQueue.main.async {
                    if project.events.isEmpty {
                        self.ui.state = .noEvents(project)
                    } else {
                        self.ui.state = .data(project: project,
                                              title: title,
                                              projectReference: projectReference)
                    }
                    
                    self.delegate?.didLoadProject(
                        project: project,
                        projectReference: projectReference)
                }
            }
        }
    }
    
    private func loadAndInsert(
        projectReference: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ project: Project,
                            _ title: String,
                            _ projectReference: ProjectReference) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        os_log("will read \(projectReference.activityLogURL), depsURL \(String(describing: projectReference.depsURL))")
        
        do {
            let project = try parser.parse(
                projectReference: projectReference,
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
    
    private func updateWithFilter(
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
