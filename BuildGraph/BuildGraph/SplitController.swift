//
//  SplitController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import AppKit

import BuildParser

class SplitController: NSSplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects.delegate = self
        detail.delegate = self
    }

    var projects: ProjectsViewController! {
        (splitViewItems[0].viewController as! ProjectsViewController)
    }
    
    var detail: DetailsStateViewController! {
        (splitViewItems[1].viewController as! DetailsStateViewController)
    }
}

extension SplitController: ProjectsViewControllerDelegate {
    func didSelect(project: ProjectReference) {
        detail.selectProject(project: project)
    }
}

extension SplitController: DetailsDelegate {
    func mainWindow() -> MainWindow {
        view.window as! MainWindow
    }
    
    func didLoadProject(project: ProjectReference, detailsController: DetailViewController) {
        mainWindow().sendImageToolbarItem.isEnabled = true
    }
    
    func willLoadProject(project: ProjectReference) {
        mainWindow().sendImageToolbarItem.isEnabled = false
    }
}
