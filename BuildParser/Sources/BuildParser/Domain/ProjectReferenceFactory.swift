//
//  ProjectReferenceFactory.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import Foundation
import XCLogParser

public class ProjectReferenceFactory {
    public init() {}
    
    public func projectReference(
        activityLogURL: URL,
        accessedDerivedDataURL: URL // TODO: Can be ommited?
    ) -> ProjectReference {
    
        let folderWithName = activityLogURL.pathComponents[activityLogURL.pathComponents.count - 4]
        let name = ProjectReference.shortName(from: folderWithName)

        let rootPathForProject = activityLogURL
            .deletingLastPathComponent() // Skip Name of file
            .deletingLastPathComponent() // Skip Build folder
            .deletingLastPathComponent() // Skip Logs folder
        
        let logFinder = LogFinder(
            derivedDataDir: rootPathForProject)

        return ProjectReference(name: name,
                                activityLogURL: [activityLogURL],
                                depsURL: try? logFinder.buildGraphURL())
    }
    
    public func projectReference(
        accessedDerivedDataURL: URL,
        fullName: String
    ) -> ProjectReference? {
        let shortName = ProjectReference.shortName(from: fullName)
        
        let logFinder = LogFinder(derivedDataDir: accessedDerivedDataURL.appendingPathComponent(fullName))
        
        do {
            let activityLogURL = try logFinder.activityLogs()
            let logsWithContent = logsWithContent(urls: activityLogURL)
            
            guard logsWithContent.count > 0 else {
                return nil
            }
            
            return ProjectReference(name: shortName,
                                    activityLogURL: logsWithContent,
                                    depsURL: try? logFinder.buildGraphURL())
        } catch {
            print("skip \(shortName), can't find .activityLog with build information")
            return nil
        }
    }
    
    private func logsWithContent(urls: [URL]) -> [URL] {
        urls.compactMap { url  in
            guard let attr = try? FileManager.default.attributesOfItem(atPath: url.path) else {
                return nil
            }
            
            guard (attr[.size] as? UInt64 ?? 0) > 0 else {
                return nil
            }
            
            return url
        }
    }
}
