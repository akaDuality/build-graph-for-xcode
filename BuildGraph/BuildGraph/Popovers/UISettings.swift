//
//  UISettings.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 26.10.2021.
//

import Foundation
import BuildParser

class UISettings {
    @Storage(key: "showSubtask", defaultValue: false)
    var showSubtask: Bool
    
    @Storage(key: "showLinks", defaultValue: false)
    var showLinks: Bool
    
    @Storage(key: "showPerformance", defaultValue: false)
    var showPerformance: Bool
    
    @Storage(key: "selectedProject", defaultValue: nil)
    var selectedProject: String?
    
    func removeSelectedProject() {
        UserDefaults.standard.removeObject(forKey: "selectedProject")
    }
    
    @Storage(key: "showLegend", defaultValue: true)
    var showLegend: Bool
    
    @Storage(key: "textSize", defaultValue: 10)
    var textSize: Int
}


