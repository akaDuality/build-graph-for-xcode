//
//  DetailsStatePresenter.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 13.02.2022.
//

import Foundation
import BuildParser
import GraphParser

//protocol DetailStateUIProtocol {
//
//}

class DetailsStatePresenter {
    //    weak var ui: DetailStateUIProtocol?
    
    let parser = RealBuildLogParser()
    
    private var cachedDependencies: [Dependency]?
    
    func loadAndInsert(
        project: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ events: [Event],
                            _ deps: [Dependency],
                            _ title: String,
                            _ project: ProjectReference) -> Void,
        didFail: @escaping (_ error: String) -> Void
    ) {
        Task {
            print("will read \(project.activityLogURL), depsURL \(String(describing: project.depsURL))")
            
            do {
                // TODO: how this try is handled?
                let events = try await events(currentActivityLog: project.currentActivityLog, filter: filter)
                let dependencies = await dependencies(depsURL: project.depsURL)
                cachedDependencies = dependencies
                
                events.connect(by: dependencies)
                
                guard events.count > 0 else {
                    // TODO: depends on compilationOnly flag
                    didFail(ParsingError.noEventsFound.localizedDescription)
                    return
                }
                
                didLoad(events, cachedDependencies ?? [], self.parser.title, project)
            } catch let error {
                didFail(error.localizedDescription)
            }
        }
    }
    
    func updateWithFilter(
        project: ProjectReference,
        filter: FilterSettings,
        didLoad: @escaping (_ events: [Event], _ deps: [Dependency], _ title: String) -> Void
    ) {
        let events = parser.update(with: filter)
        
        if let dependencies = cachedDependencies {
            events.connect(by: dependencies)
        }
        
        didLoad(events, cachedDependencies ?? [], parser.title)
    }
    
    private func events(currentActivityLog: URL, filter: FilterSettings) async throws -> [Event] {
        try parser.parse(
            logURL: currentActivityLog,
            filter: filter)
    }
    
    private func dependencies(depsURL: URL?) async -> [Dependency] {
        var dependencies = [Dependency]()
        
        if let depsURL = depsURL {
            if let depsContent = try? String(contentsOf: depsURL) {
                dependencies = DependencyParser().parseFile(depsContent)
            } else {
                // TODO: Log
            }
        }
        return dependencies
    }
}


enum ParsingError: Error {
    case noEventsFound
}

extension ParsingError: CustomNSError {
    var localizedDescription: String {
        switch self {
        case .noEventsFound: return NSLocalizedString("No compilation data found", comment: "")
        }
    }
}
