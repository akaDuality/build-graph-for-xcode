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
    func didSelect(project: ProjectReference) {
        let derivedData = FileAccess().accessedDerivedDataURL()
        derivedData?.startAccessingSecurityScopedResource()
        
        // Remove current project in case if I wouldn't open selected.
        // In case of crash, next time user will select another one
        self.uiSettings.removeSelectedProject()
        
        detail.loadAndInsert(
            activityLogURL: project.activityLogURL,
            depsURL: project.depsURL) {
                derivedData?.stopAccessingSecurityScopedResource()
                self.uiSettings.selectedProject = project.name // Save only after success parsing
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
