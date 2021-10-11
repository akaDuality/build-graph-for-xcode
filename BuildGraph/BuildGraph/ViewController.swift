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
//    var scrollView: NSScrollView {
//        view as! NSScrollView
//    }
    @IBOutlet weak var scrollView: NSScrollView!
    let contentView = FlippedView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = Bundle.main.url(forResource: "TestEvents", withExtension: "json")!
        let events = try! BuildLogParser().parse(path: url)
        layer = Graph(
            events: events)
        layer.contentsScale = NSScreen.main!.backingScaleFactor
        
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
//        scrollView.contentView.scroll(
//            to: CGPoint(x: 0,
//                        y: contentView.frame.size.height))
        
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
        print(coordinate)
        
        layer.highlightEvent(at: coordinate)
//                                CGPoint(
//            x: coordinate.x,
//            y: scrollView.frame.height - coo))
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        layer.highlightedEvent = nil
    }
}
