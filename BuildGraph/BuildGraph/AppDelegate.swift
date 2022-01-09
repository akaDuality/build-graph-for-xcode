//
//  AppDelegate.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
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
        
        let project = ProjectReference(path: filename)
        
        windowController.splitViewController().detail.selectProject(project: project)
        
        return true
    }
}

