//
//  FileLocationSelector.swift
//  Details
//
//  Created by Mikhail Rubanov on 26.04.2022.
//

import Foundation
import AppKit
import BuildParser

class FileLocationSelector {
    func requestLocation(
        project: ProjectReference?,
        title: String,
        fileExtension: String,
        then completion: @escaping (URL) -> Void
    ) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "\(fileName(for: project, title: title)).\(fileExtension)"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result == .OK {
                completion(savePanel.url!)
            }
        }
    }
    
    private func fileName(for project: ProjectReference?, title: String?) -> String {
        guard let project = project else {
            return (title ?? Date().description)
        }
        
        return ProjectDescriptionService().description(for: project)
    }
}

fileprivate extension String {
    var appedingPngFormat: Self {
        (self) + ".png"
    }
}
