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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects.delegate = self
        detail.delegate = self
    }

    var projects: ProjectsOutlineViewController! {
        (splitViewItems[0].viewController as! ProjectsOutlineViewController)
    }
    
    var detail: DetailsStateViewController! {
        (splitViewItems[1].viewController as! DetailsStateViewController)
    }
}

extension SplitController: ProjectsSelectionDelegate {
    func didSelect(project: ProjectReference) {
        detail.selectProject(project: project)
    }
}

extension SplitController: DetailsDelegate {
    func mainWindow() -> MainWindow {
        view.window as! MainWindow
    }
    
    func willLoadProject(project: ProjectReference) {
        // Remove current project in case if I wouldn't open selected.
        // In case of crash, next time user will select another one
        uiSettings.removeSelectedProject()
        mainWindow().sendImageToolbarItem.isEnabled = false
        
        updateNavigationButtons(for: project)
    }
    
    func didLoadProject(project: ProjectReference, detailsController: DetailViewController) {
        self.uiSettings.selectedProject = project.name // Save only after success parsing
        mainWindow().sendImageToolbarItem.isEnabled = true
    }
    
    func updateNavigationButtons(for project: ProjectReference) {
        mainWindow().previousButton.isEnabled = project.canIncreaseFile()
        mainWindow().nextButton.isEnabled = project.canDecreaseFile()
        
        mainWindow().subtitle = project.indexDescription
    }
}
