//
//  SplitController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import Foundation
import AppKit

import BuildParser
import XCLogParser

class SplitController: NSSplitViewController {
    
    
    private let uiSettings = UISettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects.delegate = self
        
        let pathFinder = PathFinder(logOptions: .empty)
        projects.projects = try! pathFinder.projects()
        
        if let selectedProject = uiSettings.selectedProject {
            projects.select(project: selectedProject)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.toolbar = detail.toolbar
    }
    
    var projects: ProjectsViewController! {
        (splitViewItems[0].viewController as! ProjectsViewController)
    }
    
    var detail: DetailViewController! {
        (splitViewItems[1].viewController as! DetailViewController)
    }
}

extension SplitController: ProjectsViewControllerDelegate {
    func didSelect(project: String) {
        // Remove current project in case if I wouldn't open selected.
        // In case of crash, next time user will select another one
        
        let options = LogOptions.with(projectName: project)
        let pathFinder = PathFinder(logOptions: options)
        
        do {
            let activityLogURL = try pathFinder.activityLogURL()
            let depsURL = try? pathFinder.buildGraphURL()
            
            self.uiSettings.removeSelectedProject()
            detail.loadAndInsert(
                activityLogURL: activityLogURL,
                depsURL: depsURL) {
                    self.uiSettings.selectedProject = project // Save only after success parsing
                }
        } catch let error {
            // TODO: Show error
            detail.clear()
        }
    }
}

extension LogOptions {
    static var empty: LogOptions {
        LogOptions(
            projectName: "",
            xcworkspacePath: "",
            xcodeprojPath: "",
            derivedDataPath: "",
            xcactivitylogPath: "",
            strictProjectName: false)
    }
}
