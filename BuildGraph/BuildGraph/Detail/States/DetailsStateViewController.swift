//
//  DetailsStateViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 03.01.2022.
//

import AppKit

import BuildParser
import Interface
import GraphParser

enum DetailsState: StateProtocol {
    case empty
    case loading
    case data(_ events: [Event], _ deps: [Dependency], _ title: String)
    case error(_ message: String, _ project: ProjectReference)
    
    static var `default`: DetailsState = .empty
}

protocol DetailsDelegate: AnyObject {
    func didLoadProject(project: ProjectReference, detailsController: DetailViewController)
    func willLoadProject(project: ProjectReference)
}

class DetailsStateViewController: StateViewController<DetailsState> {
    
    private let uiSettings = UISettings()
    
    var delegate: DetailsDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.stateFactory = { state in
            let storyboard = NSStoryboard(name: "Details", bundle: nil)
            
            switch state {
            case .empty:
                return storyboard.instantiateController(withIdentifier: "empty") as! ViewController
            case .loading:
                return storyboard.instantiateController(withIdentifier: "loading") as! ViewController
            case .data(let events, let deps, let title):
                let dataController = storyboard.instantiateController(withIdentifier: "data") as! DetailViewController
                dataController.show(events: events, deps: deps, title: title, embeddInWindow: true)
                return dataController
            case .error(let message, let project):
                // TODO: Pass message to controller
                let retryViewController = storyboard.instantiateController(withIdentifier: "retry") as! RetryViewController
                retryViewController.showNonCompilationEvents = { [unowned self] in
                    self.selectProject(project: project, compilationOnly: false)
                }
                return retryViewController
            }
        }
    }
    
    // TODO: compilationOnly should be customizable parameter. Best: allows to choose file types
    func selectProject(project: ProjectReference, compilationOnly: Bool = true) {
        let derivedData = FileAccess().accessedDerivedDataURL()
        _ = derivedData?.startAccessingSecurityScopedResource()
        
        // Remove current project in case if I wouldn't open selected.
        // In case of crash, next time user will select another one
        self.uiSettings.removeSelectedProject()
        
        self.state = .loading
        delegate?.willLoadProject(project: project)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            loadAndInsert(
                project: project,
                compilationOnly: compilationOnly,
                didLoad: { events, deps, title in
                    DispatchQueue.main.async {
                        self.state = .data(events, deps, title)
                        
                        derivedData?.stopAccessingSecurityScopedResource()
                        self.uiSettings.selectedProject = project.name // Save only after success parsing
                        
                        delegate?.didLoadProject(project: project, detailsController: self.currentController as! DetailViewController)
                    }
                },
                didFail: { message in
                    DispatchQueue.main.async {
                        derivedData?.stopAccessingSecurityScopedResource()
                        self.state = .error(message, project)
                    }
                }
            )
        }
    }
    
    let parser = RealBuildLogParser()
    
    func loadAndInsert(
        project: ProjectReference,
        compilationOnly: Bool,
        didLoad: @escaping (_ events: [Event], _ deps: [Dependency], _ title: String) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        print("will read \(project.activityLogURL), depsURL \(String(describing: project.depsURL))")
        
        do {
            let events = try parser.parse(
                logURL: project.currentActivityLog,
                compilationOnly: compilationOnly)
            
            guard events.count > 0 else {
                // TODO: depends on compilationOnly flag
                didFail(NSLocalizedString("No compilation data found", comment: ""))
                return
            }
            
            var dependencies = [Dependency]()
            
            if let depsURL = project.depsURL {
                if let depsContent = try? String(contentsOf: depsURL) {
                    dependencies = DependencyParser().parseFile(depsContent)
                } else {
                    // TODO: Log
                }
            }
            
            events.connect(by: dependencies)
            
            didLoad(events, dependencies, self.parser.title)
        } catch let error {
            didFail(error.localizedDescription)
        }
    }
}
