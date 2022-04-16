//
//  SplitController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import AppKit
import BuildParser
import Details
import Projects

class SplitController: NSSplitViewController {
    
    private let uiSettings = UISettings()
    private let projectSettings = ProjectSettings()
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
    
    func toggleSettingsSidebar() {
        if splitViewItems.count == 3 {
            hideSettingsIfNeeded()
        } else {
            showSettings()
        }
    }
}

extension SplitController: ProjectsSelectionDelegate {
    func didSelect(project: ProjectReference?) {
        detail.selectProject(projectReference: project, filter: filter)
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
        projectSettings.removeSelectedProject()
        
        mainWindow().disableButtons()
        mainWindow().updateNavigationButtons(for: project)
        
        hideSettingsIfNeeded()
    }
    
    func didLoadProject(
        project: ProjectReference,
        detailsController: DetailViewController
    ) {
        projectSettings.selectedProject = project.name // Save only after success parsing
        mainWindow().enableButtons()
        
        showSettings()
    }
    
    func didFailLoadProject() {
        showSettings()
    }
    
    private func hideSettingsIfNeeded() {
        if splitViewItems.count == 3 {
            removeSplitViewItem(splitViewItems.last!)
        }
    }
    
    private func showSettings() {
        hideSettingsIfNeeded()
        
        let filterSettingsController = SettingsPopoverViewController.load(
            with: self,
            counter: detail.presenter.parser.makeCounter())
        
        addSplitViewItem(NSSplitViewItem(sidebarWithViewController: filterSettingsController))
    }
}

extension SplitController: FilterSettingsDelegate {
    func didUpdateFilter(_ filterSettings: FilterSettings) {
        detail.updateFilterForCurrentProject(filterSettings)
    }
    
    func didUpdateUISettings() {
        guard let dataController = detail.currentController as? DetailViewController else { return }
        
        dataController.view().recreateHierarchy()
        dataController.view().showLegend = UISettings().showLegend
    }
}
