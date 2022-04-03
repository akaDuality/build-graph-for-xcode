//
//  DetailsStateViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 03.01.2022.
//

import AppKit

import BuildParser
import GraphParser

enum DetailsState: StateProtocol {
    case blank
    case noProject
    case loading
    case data(_ events: [Event], _ deps: [Dependency], _ title: String, _ project: ProjectReference)
    case error(_ message: String, _ project: ProjectReference)
    
    static var `default`: Self = .blank
}

protocol DetailsDelegate: AnyObject {
    func willLoadProject(project: ProjectReference)
    func didLoadProject(project: ProjectReference, detailsController: DetailViewController)
    func didFailLoadProject()
}

class DetailsStateViewController: StateViewController<DetailsState> {
    
    var delegate: DetailsDelegate?
    let presenter = DetailsStatePresenter()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            let storyboard = NSStoryboard(name: "Details", bundle: nil)
            
            switch state {
            case .blank:
                return storyboard.instantiateController(withIdentifier: "blank") as! ViewController
            case .noProject:
                return storyboard.instantiateController(withIdentifier: "noProject") as! ViewController
            case .loading:
                return storyboard.instantiateController(withIdentifier: "loading") as! ViewController
            case .data(let events, let deps, let title, let project):
                let dataController = storyboard.instantiateController(withIdentifier: "data") as! DetailViewController
                dataController.show(events: events,
                                    deps: deps,
                                    title: title,
                                    embeddInWindow: true,
                                    project: project)
                return dataController
            case .error(let message, let project):
                // TODO: Pass message to controller
                let retryViewController = storyboard.instantiateController(withIdentifier: "retry") as! RetryViewController
                return retryViewController
            }
        }
    }
    
    var currentProject: ProjectReference?
    
    func selectProject(project: ProjectReference?, filter: FilterSettings) {
        self.currentProject = project
        
        guard let project = project else {
            self.state = .noProject
            return
        }
        
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        
        self.state = .loading
        delegate?.willLoadProject(project: project)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            presenter.loadAndInsert(
                project: project,
                filter: filter,
                didLoad: { events, deps, title, project in
                    DispatchQueue.main.async {
                        self.state = .data(events, deps, title, project)
                        
                        derivedData?.stopAccessingSecurityScopedResource()
                        
                        self.delegate?.didLoadProject(project: project, detailsController: self.currentController as! DetailViewController)
                    }
                },
                didFail: { message in
                    DispatchQueue.main.async {
                        derivedData?.stopAccessingSecurityScopedResource()
                        self.state = .error(message, project)
                        self.delegate?.didFailLoadProject()
                    }
                }
            )
        }
    }
    
    // MARK: - Update filter
    func updateFilterForCurrentProject(_ filter: FilterSettings) {
        guard let project = currentProject else {
            return
        }
        
        self.state = .loading
        delegate?.willLoadProject(project: project)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            presenter.updateWithFilter(project: project, filter: filter) { events, deps, title in
                DispatchQueue.main.async {
                    guard events.count > 0 else {
                        self.state = .error("No data for current filter", project)
                        return
                    }
                    
                    self.state = .data(events, deps, title, project)
                    
                    delegate?.didLoadProject(
                        project: project,
                        detailsController: self.currentController as! DetailViewController)
                }
            }
        }
    }
}
