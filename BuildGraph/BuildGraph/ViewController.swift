//
//  ViewController.swift
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

class ViewController: NSViewController {

    // MARK: - Toolbar
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet weak var subtaskVisibility: NSSwitch!
    @IBOutlet weak var linkVisibility: NSSwitch!
    @IBOutlet weak var performanceVisibility: NSSwitch!
    
    @IBAction func subtaskVisibilityDidChange(_ sender: NSSwitch) {
        layer.showSubtask = sender.state == .on
        uiSettings.showSubtask = layer.showSubtask
    }
    
    @IBAction func linkVisibilityDidChange(_ sender: NSSwitch) {
        layer.showLinks = sender.state == .on
        uiSettings.showLinks = layer.showLinks
    }
    @IBAction func performanceVisibilityDidChange(_ sender: NSSwitch) {
        layer.showPerformance = sender.state == .on
        uiSettings.showPerformance = layer.showPerformance
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
    var layer: AppLayer!
    @IBOutlet weak var scrollView: NSScrollView!
    let contentView = FlippedView()
    
    let pizza = LogOptions(
        projectName: "DodoPizza",
        xcworkspacePath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizza.xcworkspace",
        xcodeprojPath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizza.xcodeproj",
        derivedDataPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData",
        xcactivitylogPath: "",
        strictProjectName: false)
    
    let tuist = LogOptions(
        projectName: "DodoPizzaTuist",
        xcworkspacePath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizzaTuist.xcworkspace",
        xcodeprojPath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizza.xcodeproj",
        derivedDataPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData",
        xcactivitylogPath: "",
        strictProjectName: false)
    
    let parser = RealBuildLogParser()
    let uiSettings = UISettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let url = Bundle.main.url(forResource: "AppEventsMoveDataPerstance",
//                                  withExtension: "json")!
//        let events = try! XcodeBuildTimesParser().parse(path: url)
      
        let pathFinder = PathFinder(logOptions: pizza)
        
        let depsURL = try! pathFinder.buildGraphURL()
        let depsContent = try! String(contentsOf: depsURL)
        
        var events: [Event] = []
        
        do {
            events = try parser.parse(logURL: try pathFinder.activityLogURL())
        } catch let error {
            print(error)
        }
        
        layer = AppLayer(
            events: events,
            scale: NSScreen.main!.backingScaleFactor)
        
        layer.dependencies = DependencyParser().parseFile(depsContent)
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(layer)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        
        view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(didClick(_:))))
        
        updateState()
    }
                                  
    @objc func didClick(_ recognizer: NSClickGestureRecognizer) {
        let coordinate = recognizer.location(in: contentView)
        
        guard let event = layer.event(at: coordinate)
        else { return }
              
        parser.output(event: event)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        addMouseTracking()
        
        view.window!.toolbar = toolbar
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        let contentHeight = layer.intrinsicContentSize.height
        
        let offset: CGFloat = 10
        
        layer.updateWithoutAnimation {
            layer.frame = CGRect(x: 0, y: 0,
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
        
        layer.highlightEvent(at: coordinate)
        layer.drawConcurrency(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        layer.clearHighlightedEvent()
        layer.clearConcurrency()
    }
}
