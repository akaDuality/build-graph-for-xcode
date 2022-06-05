//
//  AppDelegate.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import Firebase
import App

class AppDelegate: CommonAppDelegate {

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
        
        super.applicationDidFinishLaunching(aNotification)
    }
}

