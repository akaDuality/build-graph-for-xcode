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
    case error(_ message: String, _ project: ProjectReference)
    
    public static var `default`: Self = .blank
}

public protocol DetailsDelegate: AnyObject {
    func willLoadProject(project: ProjectReference)
    func didLoadProject(
        project: Project,
        projectReference: ProjectReference,
        detailsController: DetailViewController
    )
    func didFailLoadProject()
}

public class DetailsStateViewController: StateViewController<DetailsState> {
    
    public var delegate: DetailsDelegate?
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
            case .error(let message, let project):
                // TODO: Pass message to controller
                let retryViewController = storyboard.instantiateController(withIdentifier: "retry") as! RetryViewController
                return retryViewController
            }
        }
    }
    
    var currentProject: ProjectReference?
    
    public func selectProject(projectReference: ProjectReference?, filter: FilterSettings) {
        self.currentProject = projectReference
        
        guard let projectReference = projectReference else {
            self.state = .noProject
            return
        }
        
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        
        self.state = .loading
        delegate?.willLoadProject(project: projectReference)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            presenter.loadAndInsert(
                projectReference: projectReference,
                filter: filter,
                didLoad: { project, title, projectReference in
                    DispatchQueue.main.async {
                        self.state = .data(project: project, title: title, projectReference: projectReference)
                        
                        derivedData?.stopAccessingSecurityScopedResource()
                        
                        self.delegate?.didLoadProject(
                            project: project,
                            projectReference: projectReference,
                            detailsController: self.currentController as! DetailViewController)
                    }
                },
                didFail: { message in
                    DispatchQueue.main.async {
                        derivedData?.stopAccessingSecurityScopedResource()
                        self.state = .error(message, projectReference)
                        self.delegate?.didFailLoadProject()
                    }
                }
            )
        }
    }
    
    // MARK: - Update filter
    public func updateFilterForCurrentProject(_ filter: FilterSettings) {
        guard let projectReference = currentProject else {
            return
        }
        
        guard case .data(let project, _, _) = self.state else {
            return
        }
        
        self.state = .loading
        delegate?.willLoadProject(project: projectReference)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            presenter.updateWithFilter(
                oldProject: project,
                projectReference: projectReference,
                filter: filter
            ) { project, title in
                
                DispatchQueue.main.async {
                    guard project.events.count > 0 else {
                        self.state = .error("No data for current filter", projectReference)
                        return
                    }
                    
                    self.state = .data(project: project,
                                       title: title,
                                       projectReference: projectReference)
                    
                    self.delegate?.didLoadProject(
                        project: project,
                        projectReference: projectReference,
                        detailsController: self.currentController as! DetailViewController)
                }
            }
        }
    }
}
