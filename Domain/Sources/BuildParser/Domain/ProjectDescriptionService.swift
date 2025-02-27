//
//  ProjectDescriptionService.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import Foundation

public class ProjectDescriptionService {
    public init() {}
    
    public func description(for project: ProjectReference) -> String {
        "\(project.name), \(dateDescription(for: project.currentActivityLog))"
    }
    
    public func dateDescription(for url: URL) -> String {
        guard let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        else { return url.lastPathComponent }
        
        return dateFormatter.string(from: creationDate)
    }
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
