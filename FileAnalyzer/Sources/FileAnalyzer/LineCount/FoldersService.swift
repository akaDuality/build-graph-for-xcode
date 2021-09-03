//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 16.06.2021.
//

import Foundation

class FoldersService {
    let folder: URL
    
    init(folder: URL) {
        self.folder = folder
    }
    
    private let fileManager = FileManager.default
    
    private let exclude = ["vendor", "KeyBindings", "fastlane", "scripts", "MindBoxNotification", "FigmaExport",
                           "DodoPizza.xcodeproj",
                           "DodoPizza.xcworkspace"]
    
    func folders() throws -> [URL] {
        let projectContent: [String] = try fileManager.contentsOfDirectory(atPath: folder.path)
        let folders = projectContent.compactMap(pathIfDirectory(file:))
        
        let filtered = folders
            .filter({ url in
                !exclude.contains(url.fileName)
            })
            .filter({ url in
                !url.fileName.starts(with: ".")
            })
        
        return filtered
    }
    
    func pathIfDirectory(file: String) -> URL? {
        let path = folder.appendingPathComponent(file)
        let isDirecrory = fileManager.directoryExists(path.path)
        return isDirecrory ? path : nil
    }
}
