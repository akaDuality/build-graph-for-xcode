//
//  ViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}

class ViewController: NSViewController {

    var layer: Graph!
    @IBOutlet weak var scrollView: NSScrollView!
    let contentView = FlippedView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "AppEvents", withExtension: "json")!
        let events = try! BuildLogParser().parse(path: url)
        layer = Graph(
            events: events,
            scale: NSScreen.main!.backingScaleFactor)
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(layer)
        layer.frame = CGRect(
            x: 0,
            y: 0,
            width: layer.intrinsicContentSize.width,
            height: layer.intrinsicContentSize.height)
        contentView.frame = layer.frame
        contentView.bounds = layer.frame

        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        
        addMouseTracking()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        addMouseTracking()
        
//        self.layer.frame = view.frame
        
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
        let coordinate = contentView.convert(
            event.locationInWindow,
            from: nil)
//        print(coordinate)
        
        layer.highlightEvent(at: coordinate)
        layer.drawConcurency(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        layer.highlightedEvent = nil
    }
}
