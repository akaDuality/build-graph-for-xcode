//
//  ProjectsPresenter.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 15.01.2022.
//

import Foundation
import BuildParser

public protocol ProjectsSelectionDelegate: AnyObject {
    func select(project: ProjectReference)
    func selectNothing()
}

public protocol ProjectsUI: AnyObject {
    var state: ProjectsState { get set }
}

// TODO: Remove public
public class ProjectsPresenter {
    
    // Dependencies
    private var projectsFinder: ProjectsFinderProtocol
    
    weak var delegate: ProjectsSelectionDelegate?
    weak var ui: ProjectsUI?
    
    // Private
    private let projectSettings = ProjectSettings()
    private(set) var projects: [ProjectReference] = []
    private let projectDescriptionService = ProjectDescriptionService()
    
    // MARK: - Init
    
    public init(
        projectSettings: ProjectSettings = ProjectSettings(),
        projectsFinder: ProjectsFinderProtocol = ProjectsFinder(),
        delegate: ProjectsSelectionDelegate
    ) {
        self.projectsFinder = projectsFinder
        self.delegate = delegate
    }
    
    // MARK: - Public
    
    /// Is called when change DerivedData's path
    func requestAccessAndReloadProjects() {
        do {
            let derivedDataPath = try projectsFinder.derivedDataPath()
            
            let newDerivedData = try FileAccess()
                .requestAccess(to: derivedDataPath)
            
            reloadProjetcs()
        } catch {
            ui?.state = .noAccessToDerivedData
        }
    }
    
    public func reloadProjetcs() {
        do {
            let derivedData = try projectsFinder.derivedDataPath()
            projects = try projectsFinder.projects(derivedDataPath: derivedData)

            guard !projects.isEmpty else {
                ui?.state = .empty(derivedData)
                return
            }

            let selectedProject = selectedProject(in: projects)
            ui?.state = .projects(selectedProject)
            
            if let selectedProject = selectedProject {
                delegate?.select(project: selectedProject)
            } else {
                delegate?.selectNothing()
            }
        } catch let error {
            ui?.state = .noAccessToDerivedData
        }
    }
    
    public func reloadProjetcs(ui: ProjectsUI) {
        self.ui = ui
        
        reloadProjetcs()
    }
    
    func selectProject(at index: Int) {
        let project = projects[index]
        delegate?.select(project: project)
    }
    
    // MARK: - Private
    
    private func selectedProject(in projects: [ProjectReference]) -> ProjectReference? {
        guard let selectedProjectName = projectSettings.selectedProject else { return nil }
        
        return projects.first(where: { project in
            project.name == selectedProjectName
        })
    }
}

// MARK: - ProjectsListDatasource

extension ProjectsPresenter: ProjectsListDatasource {
    
    func select(project: ProjectReference) {
        guard project != selectedProject(in: self.projects) else {
            return
        }
        delegate?.select(project: project)
    }
    
    func changeBuild(project: ProjectReference, lastBuildIndex: Int) {
        guard project != selectedProject(in: self.projects)
                || project.currentActivityLogIndex != lastBuildIndex else {
            return
        }
        delegate?.select(project: project)
    }
    
    func shouldSelectProject(project: ProjectReference) -> Bool {
        return project == selectedProject(in: self.projects)
    }
    
    func description(for url: URL) -> String {
        projectDescriptionService.dateDescription(for: url)
    }
    
    func tooltip(for url: URL) -> String {
        url.lastPathComponent.components(separatedBy: ".").first ?? url.lastPathComponent
    }
}
