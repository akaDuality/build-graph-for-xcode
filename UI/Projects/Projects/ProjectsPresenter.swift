//
//  ProjectsPresenter.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 15.01.2022.
//

import Foundation
import BuildParser

public protocol ProjectsSelectionDelegate: AnyObject {
    func didSelect(project: ProjectReference?)
    func didSelectNothing()
}

public protocol ProjectsUI: AnyObject {
    var state: ProjectsState { get set }
}

public class ProjectSettings {
    public init() {}
    
    @Storage(key: "selectedProject", defaultValue: nil)
    public var selectedProject: String?
    
    public func removeSelectedProject() {
        UserDefaults.standard.removeObject(forKey: "selectedProject")
    }
}

// TODO: Remove public
public class ProjectsPresenter {
    
    public init(delegate: ProjectsSelectionDelegate) {
        self.delegate = delegate
    }
    
    weak var delegate: ProjectsSelectionDelegate?
    weak var ui: ProjectsUI?
    
    private let projectSettings = ProjectSettings()
    
    func requestAccessAndReloadProjects() {
        do {
            let pathFinder = ProjectsFinder()
            let derivedDataPath = try pathFinder.derivedDataPath()
            
            let newDerivedData = try FileAccess()
                .requestAccess(to: derivedDataPath)
            
            reloadProjetcs()
        } catch {
            ui?.state = .noAccessToDerivedData
        }
    }
    
    public func reloadProjetcs() {
        do {
            let pathFinder = ProjectsFinder()
            let derivedData = try pathFinder.derivedDataPath()
            projects = try pathFinder.projects(derivedDataPath: derivedData)

            guard !projects.isEmpty else {
                ui?.state = .empty(derivedData)
                return
            }

            let selectedProject = selectedProject(in: projects)
            ui?.state = .projects(selectedProject)
            
            if selectedProject == nil {
                delegate?.didSelectNothing()
            }
        } catch let error {
            ui?.state = .noAccessToDerivedData
        }
    }
    
    public func reloadProjetcs(ui: ProjectsUI) {
        self.ui = ui
        
        reloadProjetcs()
    }
    
    private func selectedProject(in projects: [ProjectReference]) -> ProjectReference? {
        guard let selectedProjectName = projectSettings.selectedProject else { return nil }
        
        return projects.first(where: { project in
            project.name == selectedProjectName
        })
    }
    
    private(set) var projects: [ProjectReference] = []
    
    
    func select(project: ProjectReference) {
        delegate?.didSelect(project: project)
    }
    
    func selectProject(at index: Int) {
        let project = projects[index]
        delegate?.didSelect(project: project)
    }

    private let projectDescriptionService = ProjectDescriptionService()
}

extension ProjectsPresenter: ProjectsListDatasource {
    func description(for url: URL) -> String {
        projectDescriptionService.dateDescription(for: url)
    }
    
    func tooltip(for url: URL) -> String {
        url.lastPathComponent.components(separatedBy: ".").first ?? url.lastPathComponent
    }
}
