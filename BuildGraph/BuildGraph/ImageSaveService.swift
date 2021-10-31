//
//  ImageSaveService.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 31.10.2021.
//

import Foundation
import AppKit

class ImageSaveService {
    func saveImage(name: String, view: NSView) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = name
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result == .OK {
                self.save(url: savePanel.url!,
                          view: view)
            }
        }
    }
    
    func save(url: URL, view: NSView) {
        let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
        view.cacheDisplay(in: view.bounds, to: rep)
        
        let img = NSImage(size: view.bounds.size)
        img.addRepresentation(rep)
        
        let png = UIImagePNGRepresentation(img)
        
        do {
            try png?.write(to: url)
        } catch let error {
            print(error)
        }
    }
}

public func UIImagePNGRepresentation(_ image: NSImage) -> Data? {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else { return nil }
    let imageRep = NSBitmapImageRep(cgImage: cgImage)
    imageRep.size = image.size // display size in points
    return imageRep.representation(using: .png, properties: [:])
}
