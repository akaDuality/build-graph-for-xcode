//
//  ProjectsStateViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import Foundation
import BuildParser
import AppKit

enum ProjectsState: StateProtocol {
    case loading
    case empty(_ derivedDataURL: URL)
    case projects(_ selectedProject: ProjectReference?)
    
    static var `default`: Self = .loading
}

class ProjectsStateViewController: StateViewController<ProjectsState>, ProjectsUI {
    
    var presenter: ProjectsPresenter!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            let storyboard = NSStoryboard(name: "Projects", bundle: nil)
            
            switch state {
            case .loading:
                return storyboard.instantiateController(withIdentifier: "loading") as! ViewController
                
            case .empty(let derivedDataURL):
                let controller = storyboard.instantiateController(withIdentifier: "empty") as! NoProjectsViewController
                controller.view().derivedData = derivedDataURL
                controller.delegate = self.presenter
                return controller
                
            case .projects(let selectedProject):
                let controller = storyboard.instantiateController(withIdentifier: "projects") as! ProjectsOutlineViewController
                controller.presenter = self.presenter
                
                if let selectedProject = selectedProject {
                    controller.select(project: selectedProject)
                }
                
                return controller
            }
        }
    }
}

extension ProjectsPresenter: NoProjectsDelegate {}
