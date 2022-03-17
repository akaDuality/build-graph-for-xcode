//
//  SplitController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import AppKit

import BuildParser

class SplitController: NSSplitViewController {
    
    private let uiSettings = UISettings()
    var filter = FilterSettings.shared
    
    var projectsPresenter: ProjectsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.projectsPresenter = ProjectsPresenter(delegate: self) // TODO: Not self, should be another delegate
        detail.delegate = self
        projects.presenter = projectsPresenter
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        projectsPresenter.reloadProjetcs(ui: projects)
        
        mainWindow().setupToolbar()
    }

    var projects: ProjectsStateViewController! {
        (splitViewItems[0].viewController as! ProjectsStateViewController)
    }
    
    var detail: DetailsStateViewController! {
        (splitViewItems[1].viewController as! DetailsStateViewController)
    }
}

extension SplitController: ProjectsSelectionDelegate {
    func didSelect(project: ProjectReference?) {
        detail.selectProject(project: project, filter: filter)
    }
}

extension SplitController: DetailsDelegate {
    func mainWindow() -> MainWindow {
        view.window as! MainWindow
    }
    
    func willLoadProject(
        project: ProjectReference
    ) {
        // Remove current project in case if I wouldn't open selected.
        // In case of crash, next time user will select another one
        uiSettings.removeSelectedProject()
        
        mainWindow().disableButtons()
        mainWindow().updateNavigationButtons(for: project)
    }
    
    func didLoadProject(
        project: ProjectReference,
        detailsController: DetailViewController
    ) {
        self.uiSettings.selectedProject = project.name // Save only after success parsing
        mainWindow().enableButtons()
    }
}

extension SplitController: FilterSettingsDelegate {
    func didUpdateFilter(_ filterSettings: FilterSettings) {
        detail.updateFilterForCurrentProject(filterSettings)
    }
}
