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
import Filters

extension UISettings: GraphConfig {}

class SplitController: NSSplitViewController {
    
    private let uiSettings = UISettings()
    private let projectSettings = ProjectSettings()
    var filter = FilterSettings.shared
    
    var projectsPresenter: ProjectsPresenter!
    let appReview = AppReview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.projectsPresenter = ProjectsPresenter(delegate: self) // TODO: Not self, should be another delegate
        detail.presenter.delegate = self
        detail.graphConfig = UISettings()
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
    func selectNothing() {
        detail.state = .noProject
    }
    
    func select(project: ProjectReference) {
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
        project: Project,
        projectReference: ProjectReference
    ) {
        projectSettings.selectedProject = projectReference.name // Save only after success parsing
        mainWindow().enableButtons()
        mainWindow().updateNavigationButtons(for: projectReference,
                                             buildDuration: project.events.duration())
        showSettings()
        
        appReview.requestIfPossible()
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
