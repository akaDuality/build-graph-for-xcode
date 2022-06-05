//
//  AppDelegate.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import Firebase
import App

class AppDelegate: NSObject, NSApplicationDelegate {

    private var windowController: NSWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
        
        windowController = WindowController.fromStoryboard()
        windowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        guard let windowController = NSApplication.shared.windows
            .first?
            .windowController as? WindowController
        else {
            return false
        }
        
        let fileURL = URL(fileURLWithPath: filename)
        windowController.open(from: fileURL)
        
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

