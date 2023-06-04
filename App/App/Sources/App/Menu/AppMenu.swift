//
//  AppMenu.swift
//  App
//
//  Created by Mikhail Rubanov on 06.06.2022.
//

import AppKit

public class AppMenu: NSMenu {
    public static func menu() -> NSMenu {
        var topLevelObjects: NSArray? = []
        
        Bundle.module
            .loadNibNamed("Application", owner: self, topLevelObjects: &topLevelObjects)
        
        return topLevelObjects?.filter { $0 is NSMenu }.first as! NSMenu
    }
}
