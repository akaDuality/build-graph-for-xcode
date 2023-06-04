//
//  ProjectsFinderMock.swift
//  ProjectsTests
//
//  Created by Mikhail Rubanov on 22.05.2022.
//

import BuildParser
import Foundation

class ProjectsFinderMock: ProjectsFinderProtocol {
    var projects = [ProjectReference]()
    func projects(derivedDataPath: URL) throws -> [ProjectReference] {
        return projects
    }
    
    var derivedDataPathResult: Result<URL, Error> = .failure(ProjectsFinder.Error.noDerivedData)
    func derivedDataPath() throws -> URL {
        switch derivedDataPathResult {
        case .success(let url): return url
        case .failure(let error): throw error
        }
    }
}
