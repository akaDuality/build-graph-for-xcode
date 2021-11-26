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
        
        let pathFinder = FileAccess().pathFinder(for: project)
        
        do {
            let derivedData = FileAccess().accessedDerivedDataURL()
            derivedData?.startAccessingSecurityScopedResource()
            
            let activityLogURL = try pathFinder.activityLogURL()
            let depsURL = try? pathFinder.buildGraphURL()
            
            // Remove current project in case if I wouldn't open selected.
            // In case of crash, next time user will select another one
            self.uiSettings.removeSelectedProject()
            
            detail.loadAndInsert(
                activityLogURL: activityLogURL,
                depsURL: depsURL) {
                    derivedData?.stopAccessingSecurityScopedResource()
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
            derivedDataPath: nil,
            xcactivitylogPath: "",
            strictProjectName: false)
    }
}

//extension LogOptions {
//    static func with(projectName: String) -> Self {
//        LogOptions(
//            projectName: projectName,
//            xcworkspacePath: "",
//            xcodeprojPath: "",
//            derivedDataPath: "",
//            xcactivitylogPath: "",
//            strictProjectName: false)
//    }
//}
