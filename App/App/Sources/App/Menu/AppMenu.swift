//
//  AppMenu.swift
//  App
//
//  Created by Mikhail Rubanov on 06.06.2022.
//

import AppKit
import Filters

public class AppMenu: NSMenu {
    public static func menu() -> NSMenu {
        var topLevelObjects: NSArray? = []
        
        Bundle.module
            .loadNibNamed("Application", owner: self, topLevelObjects: &topLevelObjects)
        
        let menu = topLevelObjects?.filter { $0 is NSMenu }.first as! AppMenu
        
        return menu
    }
}
