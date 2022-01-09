//
//  ProjectReferenceFactory.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import Foundation

public class ProjectReferenceFactory {
    public init() {}
    
    public func projectReference(
        activityLogURL: URL,
        accessedDerivedDataURL: URL // TODO: Can be ommited?
    ) -> ProjectReference {
        let folderWithName = activityLogURL.pathComponents[activityLogURL.pathComponents.count - 4]
        let name = ProjectReference.shortName(from: folderWithName)
        
        let pathFinder = PathFinder.pathFinder(
            for: name,
            derivedDataPath: accessedDerivedDataURL)
        
        return ProjectReference(name: ProjectReference.shortName(from: folderWithName),
                                activityLogURL: activityLogURL,
                                depsURL: try? pathFinder.buildGraphURL())
    }
    
    public func projectReference(
        accessedDerivedDataURL: URL,
        fullName: String
    ) -> ProjectReference? {
        let shortName = ProjectReference.shortName(from: fullName)
        
        let pathFinder = PathFinder.pathFinder(
            for: shortName,
            derivedDataPath: accessedDerivedDataURL)
        
        do {
            return ProjectReference(name: shortName,
                                    activityLogURL: try pathFinder.activityLogURL(),
                                    depsURL: try? pathFinder.buildGraphURL())
        } catch {
            print("skip \(shortName), can't find .activityLog with build information")
            return nil
        }
    }
}
