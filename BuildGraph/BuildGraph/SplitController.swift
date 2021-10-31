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
    
    var projects: ProjectsViewController! {
        (splitViewItems[0].viewController as! ProjectsViewController)
    }
    
    var detail: DetaliViewController! {
        (splitViewItems[1].viewController as! DetaliViewController)
    }
}

extension SplitController: ProjectsViewControllerDelegate {
    func didSelect(project: String) {
        let options = LogOptions(
            projectName: project,
            xcworkspacePath: "",
            xcodeprojPath: "",
            derivedDataPath: "",
            xcactivitylogPath: "",
            strictProjectName: false)
       
        let pathFinder = PathFinder(logOptions: options)
        
        do {
            let activityLogURL = try pathFinder.activityLogURL()
            let depsURL = try? pathFinder.buildGraphURL()
            
            detail.loadAndInsert(
                activityLogURL: activityLogURL,
                depsURL: depsURL) {
                    self.uiSettings.selectedProject = project // Save only after success parsing
                }
        } catch let error {
            // TODO: Handle
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
