//
//  DetailsStateViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 03.01.2022.
//

import AppKit

import BuildParser
import GraphParser

public enum DetailsState: StateProtocol {
    case blank
    case noProject
    case loading
    case data(project: Project, title: String, projectReference: ProjectReference)
    case noEvents(_ project: Project)
    case cantRead(projectReference: ProjectReference)
    
    public static var `default`: Self = .blank
}

public protocol DetailsDelegate: AnyObject {
    func willLoadProject(project: ProjectReference)
    func didLoadProject(
        project: Project,
        projectReference: ProjectReference
    )
    func didFailLoadProject(projectReference: ProjectReference)
}

public class DetailsStateViewController: StateViewController<DetailsState> {
    
    public let presenter = DetailsStatePresenter()
    public var graphConfig: GraphConfig!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            let storyboard = NSStoryboard(name: "Details", bundle: Bundle(for: type(of: self)))
            
            switch state {
            case .blank:
                return storyboard.instantiateController(withIdentifier: "blank") as! ViewController
            case .noProject:
                return storyboard.instantiateController(withIdentifier: "noProject") as! ViewController
            case .loading:
                return storyboard.instantiateController(withIdentifier: "loading") as! ViewController
            case .data(let project, let title, let projectReference):
                let dataController = storyboard.instantiateController(withIdentifier: "data") as! DetailViewController
                dataController.show(project: project,
                                    title: title,
                                    embeddInWindow: true,
                                    projectReference: projectReference,
                                    graphConfig: self.graphConfig)
                return dataController
            case .noEvents(let project):
                let retryViewController = storyboard.instantiateController(withIdentifier: "retry") as! RetryViewController
                return retryViewController
    
            case .cantRead(let projecReference):
                // TODO: Handle
                let controller = NSViewController()
                return controller
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.ui = self
    }
    
    public func selectProject(projectReference: ProjectReference, filter: FilterSettings) {
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        
        presenter.openProject(
            projectReference: projectReference,
            filter: filter) {
                derivedData?.stopAccessingSecurityScopedResource()
            }
    }
    
    func projectFromCurrentState() -> Project? {
        switch state {
        case .noEvents(let project):
            return project
        case .data(project: let project, title: _, projectReference: _):
            return project
        default:
            return nil
        }
    }
    
    // MARK: - Update filter
    public func updateFilterForCurrentProject(_ filter: FilterSettings) {
        guard let project = projectFromCurrentState() else {
            return
        }
        presenter.updateFilterForCurrentProject(project: project, filter: filter)
    }
}

extension DetailsStateViewController: DetailStateUIProtocol {}
