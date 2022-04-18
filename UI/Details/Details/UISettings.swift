//
//  UISettings.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 26.10.2021.
//

import Foundation
import BuildParser

public class UISettings {
    public init() {}
    
//    @Storage(key: "showSubtask", defaultValue: false)
//    public var showSubtask: Bool
//
//    @Storage(key: "showLinks", defaultValue: false)
//    public var showLinks: Bool
//    
//    @Storage(key: "showPerformance", defaultValue: false)
//    public var showPerformance: Bool
    
    @Storage(key: "showLegend", defaultValue: true)
    public var showLegend: Bool
    
    @Storage(key: "textSize", defaultValue: 10)
    public var textSize: Int
}


