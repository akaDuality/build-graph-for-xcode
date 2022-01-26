//
//  ProjectsPresenter.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 15.01.2022.
//

import Foundation
import BuildParser

protocol ProjectsSelectionDelegate: AnyObject {
    func didSelect(project: ProjectReference)
}

protocol ProjectsUI: AnyObject {
    func reloadData()
    func select(project: ProjectReference)
}

class ProjectsPresenter {
    
    init(delegate: ProjectsSelectionDelegate) {
        self.delegate = delegate
    }
    
    weak var delegate: ProjectsSelectionDelegate?
    weak var ui: ProjectsUI?
    
    private let uiSettings = UISettings()
    private let projectDescriptionService = ProjectDescriptionService()
    
    @objc func reloadProjetcs() {
        let pathFinder = ProjectsFinder()
        projects = try! pathFinder.projects()
        
        if let selectedProject = uiSettings.selectedProject {
            select(name: selectedProject)
        }
    }
    
    func select(name: String) {
        guard let project = projects.first(where: { project in
            project.name == name
        }) else {
            return
        }
        
        ui?.select(project: project)
        delegate?.didSelect(project: project)
    }
    
    func select(project: ProjectReference) {
        delegate?.didSelect(project: project)
    }
    
    private(set) var projects: [ProjectReference] = [] {
        didSet {
            ui?.reloadData()
        }
    }
    
    func selectProject(at index: Int) {
        let project = projects[index]
        delegate?.didSelect(project: project)
    }
    
    func description(for url: URL) -> String {
        projectDescriptionService.dateDescription(for: url)
    }
    
    func tooltip(for url: URL) -> String {
        url.lastPathComponent.components(separatedBy: ".").first ?? url.lastPathComponent
    }
}

class ProjectDescriptionService {
    func description(for project: ProjectReference) -> String {
        "\(project.name), \(dateDescription(for: project.currentActivityLog))"
    }
        
    func dateDescription(for url: URL) -> String {
        guard let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        else { return url.lastPathComponent }
        
        return dateFormatter.string(from: creationDate)
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
