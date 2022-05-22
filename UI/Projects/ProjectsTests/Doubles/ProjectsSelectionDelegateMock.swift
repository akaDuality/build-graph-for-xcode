//
//  ProjectsSelectionDelegateMock.swift
//  ProjectsTests
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import Projects
import BuildParser

class ProjectsSelectionDelegateMock: ProjectsSelectionDelegate {
    var selectedProject: ProjectReference?
    func select(project: ProjectReference) {
        self.selectedProject = project
    }
    
    var didSelectNothing = false
    func selectNothing() {
        self.didSelectNothing = true
    }
    
    // TODO: В тестах проще проверять вызов одного метода, можно сделать проект опциональным (обратно, да))
}
