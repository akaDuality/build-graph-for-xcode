//
//  CommonAppDelegate.swift
//  App
//
//  Created by Mikhail Rubanov on 06.06.2022.
//

import AppKit

open class CommonAppDelegate: NSObject, NSApplicationDelegate {
    
    private var windowController: NSWindowController!
    
    open func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowController = WindowController.fromStoryboard()
        windowController.showWindow(self)
        
        NSApplication.shared.mainMenu = AppMenu.menu()
    }
    
    public func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    public func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
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
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
