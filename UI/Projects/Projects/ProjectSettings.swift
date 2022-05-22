//
//  ProjectSettings.swift
//  Projects
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import BuildParser

public class ProjectSettings {
    public init() {}
    
    @Storage(key: "selectedProject", defaultValue: nil)
    public var selectedProject: String?
    
    public func removeSelectedProject() {
        UserDefaults.standard.removeObject(forKey: "selectedProject")
    }
}
