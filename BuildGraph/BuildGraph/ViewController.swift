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
    
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBAction func refresh(_ sender: Any) {
        layer?.removeFromSuperlayer()
        loadAndInsert()
    }
    
    func loadAndInsert() {
        loadingIndicator.startAnimation(self)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            //        let url = Bundle.main.url(forResource: "AppEventsMoveDataPerstance",
            //                                  withExtension: "json")!
            //        let events = try! XcodeBuildTimesParser().parse(path: url)
            
            let pathFinder = PathFinder(logOptions: pizza)
            
            var events: [Event] = []
            
            do {
                let activityLogURL = try pathFinder.activityLogURL()
                //            let activityLogURL = URL(fileURLWithPath: "/Users/rubanov/Downloads/Logs 2/Build/4632A877-8B5B-437C-8DD9-B6C545839F13.xcactivitylog")
                events = try parser.parse(logURL: activityLogURL)
                
                let depsURL = try pathFinder.buildGraphURL()
                let depsContent = try String(contentsOf: depsURL)
                let dependencies = DependencyParser().parseFile(depsContent)
                
                DispatchQueue.main.async {
                    showEvents(events: events, deps: dependencies)
                }
                
            } catch let error {
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
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(layer!)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        
        loadingIndicator.stopAnimation(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
                                  
    @objc func didClick(_ recognizer: NSClickGestureRecognizer) {
        let coordinate = recognizer.location(in: contentView)
        
        guard let event = layer?.event(at: coordinate)
        else { return }
              
        parser.output(event: event)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.toolbar = toolbar
        
        loadAndInsert()
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
