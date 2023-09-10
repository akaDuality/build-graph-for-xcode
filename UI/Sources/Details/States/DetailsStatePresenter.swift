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

public struct ParsedProject: Equatable {
    let project: Project
    let title: String
    let reference: ProjectReference
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
        
        Task {
            do {
                let parsedProject = try await loadAndInsert(
                    projectReference: projectReference,
                    filter: filter)
                
                await MainActor.run {
                    if parsedProject.project.events.isEmpty {
                        self.ui.state = .noEvents(parsedProject.project)
                    } else {
                        self.ui.state = .data(parsedProject: parsedProject)
                    }
                    
                    self.delegate?.didLoadProject(
                        project: parsedProject.project,
                        projectReference: parsedProject.reference)
                    completion()
                }
            } catch let error {
                await MainActor.run {
                    // TODO: Sepatate to another state and pass message
                    self.ui.state = .cantRead(projectReference: projectReference)
                    self.delegate?.didFailLoadProject(projectReference: projectReference)
                    completion()
                }
            }
        }
    }
    
    public func updateFilterForCurrentProject(project: Project, filter: FilterSettings) {
        guard let projectReference = currentProject else {
            return
        }
        
        self.ui.state = .loading
        delegate?.willLoadProject(project: projectReference)
        
        Task {
            let project = updateWithFilter(oldProject: project, filter: filter)
            
            let parsedProject = ParsedProject(project: project, title: parser.title, reference: projectReference)
                
            await MainActor.run {
                if project.events.isEmpty {
                    self.ui.state = .noEvents(project)
                } else {
                    self.ui.state = .data(parsedProject: parsedProject)
                }
                
                self.delegate?.didLoadProject(
                    project: project,
                    projectReference: projectReference)
            }
        }
    }
    
    private func loadAndInsert(
        projectReference: ProjectReference,
        filter: FilterSettings
    ) async throws -> ParsedProject {
        os_log("Will read: \(projectReference.activityLogURL)")
        
        let project = try parser.parse(
            projectReference: projectReference,
            filter: filter)
        
//        os_log("Dependencies: \(self.parser.depsPath?.absoluteString ?? "Unknown")")
        if let depsPath = parser.depsPath,
           let dependencies = DependencyParserWithVersions().parse(path: depsPath) {
            if dependencies.count == 0 {
                os_log("File exists, but no connections found")
            }
            project.connect(dependencies: dependencies)
        } else {
            os_log("No connections found")
        }
            
        return ParsedProject(project: project, title: parser.title, reference: projectReference)
    }
    
    func updateWithFilter(
        oldProject: Project,
        filter: FilterSettings
    ) -> Project {
        // TODO: Rework to project
        let events = parser.update(with: filter)
        
        // TODO: Create in another place
        let project = Project(events: events, relativeBuildStart: 0)
        if let dependencies = oldProject.cachedDependencies {
            project.connect(dependencies: dependencies)
        }
        
        return project
    }
}

public class DependencyParserWithVersions {
    public init() {}
    
    public func parse(path: DepedendencyPath) -> [Dependency]? {
        switch path {
        case .xcode15(let path):
            return DependencyParser15().parse(path: path)
        case .xcode14_3(let path):
            return DependencyParser().parse(path: path)
        }
    }
}
