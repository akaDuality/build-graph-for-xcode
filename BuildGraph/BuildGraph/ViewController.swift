//
//  ViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser

class ViewController: NSViewController {

    var layer: Graph!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "TestEvents", withExtension: "json")!
        let events = try! BuildLogParser().parse(path: url)
        layer = Graph(
            events: events)
        
        view.wantsLayer = true
        view.layer?.addSublayer(layer)
        
        addMouseTracking()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        addMouseTracking()
        
        self.layer.frame = view.frame
    }
    
    func addMouseTracking() {
        view.addTrackingRect(view.frame,
                             owner: self,
                             userData: nil,
                             assumeInside: false)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = true
        view.window?.makeFirstResponder(self)
    }
    
    override func mouseMoved(with event: NSEvent) {
        let coordinate = view.convert(event.locationInWindow, to: nil)
        print(coordinate)
        
        layer.highlightEvent(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
    }
}

