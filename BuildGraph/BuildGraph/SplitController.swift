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
        selectProject(project: project)
    }
    
    // TODO: compilationOnly should be customizable parameter. Best: allows to choose file types
    private func selectProject(project: ProjectReference, compilationOnly: Bool = true) {
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        
        // Remove current project in case if I wouldn't open selected.
        // In case of crash, next time user will select another one
        self.uiSettings.removeSelectedProject()
        
        //        let activityLogURL = URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Logs/Build/F9642A7B-23C1-4302-A2FC-37DCFB73E0C5.xcactivitylog")
        
        detail.loadAndInsert(
            activityLogURL: project.activityLogURL,
            depsURL: project.depsURL,
            compilationOnly: compilationOnly,
            didLoad: {
                derivedData?.stopAccessingSecurityScopedResource()
                self.uiSettings.selectedProject = project.name // Save only after success parsing
            },
            didFail: { error in
                derivedData?.stopAccessingSecurityScopedResource()
                self.showAlert(message: error, project: project)
            })
    }
    
    private func showAlert(message: String, project: ProjectReference) {
        // TODO: Show inline
        let alert = NSAlert()
        alert.messageText = message
        // TODO: think about great alerts
//        alert.informativeText = "Try to refresh projects list"
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: NSLocalizedString("Show non-compilation data", comment: "Alert action"))
        alert.addButton(withTitle: NSLocalizedString("Refresh list of projects", comment: "Alert action"))
        
        switch alert.runModal() {
        case NSApplication.ModalResponse.alertFirstButtonReturn: // non-compile data
            selectProject(project: project, compilationOnly: false)
        case NSApplication.ModalResponse.alertSecondButtonReturn: // refresh
            projects.reloadProjetcs()
            // TODO: Stop loading
        default:
            break // Impossible state
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
