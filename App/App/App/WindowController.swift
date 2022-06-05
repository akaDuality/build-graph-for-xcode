//
//  WindowController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 04.01.2022.
//

import AppKit
import Details
import Projects
import BuildParser

public class WindowController: NSWindowController, NSWindowDelegate {
    
    public static func fromStoryboard() -> NSWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: WindowController.self))
        
        return storyboard.instantiateInitialController() as! NSWindowController
    }
    
    public func open(from file: URL) {
        let project = project(from: file)
        
        selectProject(projectReference: project)
    }
    
    private func project(from fileURL: URL) -> ProjectReference {
        if fileURL.pathExtension == XcodeBuildSnapshot.bgbuildsnapshot {
            let snapshot = try! XcodeBuildSnapshot(url: fileURL)
            return snapshot.project
        } else {
            let project = projectFromActivityLog(fileURL)
            
            return project
        }
    }
    
    private func projectFromActivityLog(_ activityLog: URL) -> ProjectReference {
        // TODO: File can be outside of default derived data
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        defer {
            derivedData?.stopAccessingSecurityScopedResource()
        }
        
        let projectReferenceFactory = ProjectReferenceFactory()
        
        let project = projectReferenceFactory.projectReference(
            activityLogURL: activityLog)
        
        return project
    }
    
    func selectProject(projectReference: ProjectReference) {
        // TODO: Pass correct filter settings
        splitViewController().detail.selectProject(
            projectReference: projectReference,
            filter: .shared)
    }
    
    public override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
    }
    
    func window() -> MainWindow {
        window as! MainWindow
    }
    
    @IBAction func makeScreenshotOfGraph(_ sender: Any) {
        guard let detailController = splitViewController().detail.currentController as? DetailViewController else {
            return
        }
        
        detailController.shareImage()
    }
    
    @IBAction func searchDidChange(_ sender: NSSearchField) {
        let text = sender.stringValue
     
        guard let detailController = splitViewController().detail.currentController as? DetailViewController else { return }
        
        detailController.search(text: text)
    }
    
    @IBAction func togglesSettingsSidebar(_ sender: Any) {
        splitViewController().toggleSettingsSidebar()
    }
    
    @IBAction func previousProjectDidPress(_ sender: Any) {
        projectsController?.selectNextFile()
    }
    
    @IBAction func nextProjectDidPress(_ sender: Any) {
        projectsController?.selectPreviousFile()
    }
    
    private var projectsController: ProjectsOutlineViewController? {
        // TODO: Rework
        splitViewController().projects.currentController as? ProjectsOutlineViewController
    }
    
    func splitViewController() -> SplitController {
        return self.contentViewController as! SplitController
    }
    
    @IBAction func refresh(_ sender: Any) {
        splitViewController().projectsPresenter.reloadProjetcs()
    }
}
