//
//  ImageSaveService.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 31.10.2021.
//

import Foundation
import AppKit
import BuildParser

class ImageSaveService {
    func saveImage(url: URL, view: NSView) {
        let previousColor = view.layer?.backgroundColor
        defer {
            view.layer?.backgroundColor = previousColor
        }
        
        view.layer?.backgroundColor = NSColor.textBackgroundColor.effectiveCGColor
        
        writeToFile(url: url, view: view)
    }
    
    private func writeToFile(url: URL, view: NSView) {
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
