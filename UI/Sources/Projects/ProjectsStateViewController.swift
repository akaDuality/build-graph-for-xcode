//
//  ProjectsStateViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import Foundation
import BuildParser
import AppKit

public enum ProjectsState: StateProtocol {
    case loading
    case empty(_ derivedDataURL: URL)
    case projects(_ selectedProject: ProjectReference?)
    case noAccessToDerivedData
    
    public static var `default`: Self = .loading
}

public class ProjectsStateViewController: StateViewController<ProjectsState>, ProjectsUI {
    
    public var presenter: ProjectsPresenter!
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            let storyboard = NSStoryboard(name: "Projects", bundle: Bundle.module)
            
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
            case .noAccessToDerivedData:
                let controller = storyboard.instantiateController(withIdentifier: "noAccess") as! NoAccessViewController
                controller.delegate = self.presenter
                return controller
            }
        }
    }
}

extension ProjectsPresenter: NoProjectsDelegate {}
