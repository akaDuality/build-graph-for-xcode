//
//  DetaliViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser
import GraphParser
import Interface
import XCLogParser

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}

class DetaliViewController: NSViewController {

    // MARK: - Toolbar
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet weak var subtaskVisibility: NSSwitch!
    @IBOutlet weak var linkVisibility: NSSwitch!
    @IBOutlet weak var performanceVisibility: NSSwitch!
    
    @IBAction func subtaskVisibilityDidChange(_ sender: NSSwitch) {
        let isOn = sender.state == .on
        layer?.showSubtask = isOn
        uiSettings.showSubtask = isOn
    }
    
    @IBAction func linkVisibilityDidChange(_ sender: NSSwitch) {
        let isOn = sender.state == .on
        layer?.showLinks = isOn
        uiSettings.showLinks = isOn
    }
    @IBAction func performanceVisibilityDidChange(_ sender: NSSwitch) {
        let isOn = sender.state == .on
        layer?.showPerformance = isOn
        uiSettings.showPerformance = isOn
    }
    
    private func updateState() {
        subtaskVisibility       .state = uiSettings.showSubtask ? .on: .off
        linkVisibility          .state = uiSettings.showLinks ? .on: .off
        performanceVisibility   .state = uiSettings.showPerformance ? .on: .off
        
        subtaskVisibilityDidChange(subtaskVisibility)
        linkVisibilityDidChange(linkVisibility)
        performanceVisibilityDidChange(performanceVisibility)
    }
    
    // MARK: - Content
    var layer: AppLayer?
    @IBOutlet weak var scrollView: NSScrollView!
    let contentView = FlippedView()
    
    let parser = RealBuildLogParser()
    let uiSettings = UISettings()
    
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBAction func refresh(_ sender: Any) {
        if let activityLogURL = activityLogURL {
            loadAndInsert(activityLogURL: activityLogURL, depsURL: depsURL)
        }
    }
    
    private var activityLogURL: URL?
    private var depsURL: URL?
    
    func loadAndInsert(activityLogURL: URL, depsURL: URL?) {
        layer?.removeFromSuperlayer()
        
        self.activityLogURL = activityLogURL
        self.depsURL = depsURL
        
        loadingIndicator.startAnimation(self)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            do {
                let events = try parser.parse(logURL: activityLogURL)
                
                var dependencies = [Dependency]()
                
                if let depsURL = depsURL {
                    if let depsContent = try? String(contentsOf: depsURL) {
                        dependencies = DependencyParser().parseFile(depsContent)
                    } else {
                        // TODO: Log
                    }
                }
                
                DispatchQueue.main.async {
                    showEvents(events: events, deps: dependencies)
                }
                
            } catch let error {
                // TODO: Show on UI
                print(error)
            }
        }
    }
    
    func showEvents(events: [Event], deps: [Dependency]) {
        layer = AppLayer(
            events: events,
            scale: NSScreen.main!.backingScaleFactor)
        layer!.dependencies = deps
        view.needsLayout = true
        
        view.window?.title = parser.title
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(layer!)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        
        loadingIndicator.stopAnimation(self)
        updateState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
                                  
    @objc func didClick(_ recognizer: NSClickGestureRecognizer) {
        let coordinate = recognizer.location(in: contentView)
        
        guard let event = layer?.event(at: coordinate)
        else { return }
              
        let popover = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "DetailPopover") as! DetailPopoverController
        _ = popover.view
        popover.text = parser.description(event: event)
        
        present(popover,
                asPopoverRelativeTo: CGRect(x: coordinate.x, y: coordinate.y, width: 10, height: 10),
                of: contentView,
                preferredEdge: .maxX,
                behavior: .transient)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.toolbar = toolbar
        
        addMouseTracking()
        view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(didClick(_:))))
        updateState()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        guard let layer = layer else {
            return
        }

        let contentHeight = layer.intrinsicContentSize.height
        
        let offset: CGFloat = 10
        
        layer.updateWithoutAnimation {
            layer.frame = CGRect(
                x: 0, y: 0,
                width: view.frame.width - offset,
                height: max(contentHeight, view.frame.height))
            layer.layoutIfNeeded()
        }
        contentView.frame = layer.bounds
        contentView.bounds = layer.frame
        
        view.window?.contentMinSize = NSSize(
            width: 500,
            height: min(400, contentHeight))
    }
    
    var trackingArea: NSTrackingArea!
    func addMouseTracking() {
        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways,
                      .mouseMoved,
                      .mouseEnteredAndExited,
                      .inVisibleRect],
            owner: self,
            userInfo: nil)
        view.addTrackingArea(trackingArea)
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
        
        layer?.highlightEvent(at: coordinate)
        layer?.drawConcurrency(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        layer?.clearHighlightedEvent()
        layer?.clearConcurrency()
    }
}
