//
//  ProjectSettings.swift
//  Projects
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import BuildParser
import Foundation

protocol ProjectSettingsProtocol {
    var selectedProject: String? { get set }
}

public class ProjectSettings: ProjectSettingsProtocol {
    public init() {}
    
    @Storage(key: "selectedProject", defaultValue: nil)
    public var selectedProject: String?
    
    public func removeSelectedProject() {
        UserDefaults.standard.removeObject(forKey: "selectedProject")
    }
}
