//
//  ProjectsUIMock.swift
//  ProjectsTests
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import Projects

class ProjectsUIMock: ProjectsUI {
    var state: ProjectsState = .default {
        didSet {
            states.append(state)
        }
    }
    
    var states: [ProjectsState] = []
}
