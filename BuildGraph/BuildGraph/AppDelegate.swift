//
//  AppDelegate.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import Firebase
import BuildParser
import Details

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard let windowController = NSApplication.shared.windows.first?.windowController as? WindowController else {
            return false
        }
        
        let fileURL = URL(fileURLWithPath: filename)
        let project = project(from: fileURL)
        
        // TODO: Pass correct filter settings
        windowController.splitViewController().detail.selectProject(
            projectReference: project,
            filter: .shared)
        
        return true
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
    
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

