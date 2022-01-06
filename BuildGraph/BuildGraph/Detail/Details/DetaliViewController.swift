//
//  DetailViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser
import GraphParser
import Interface
import XCLogParser

class DetailViewController: NSViewController {
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if embeddInWindow {
//            view.window?.toolbar = toolbar
            resizeWindowHeight()
            view.window?.title = title!
        }
        
        addMouseTracking()
        view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(didClick(_:))))
        updateState()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        setModules(size: view.bounds.size)
    }
    
    private var embeddInWindow: Bool = true
    public func show(
        events: [Event],
        deps: [Dependency],
        title: String,
        embeddInWindow: Bool
    ) {
        self.title = title
        self.embeddInWindow = embeddInWindow
        view().showEvents(events: events)
        layoutModules() // calc intrinsic content size
        
        updateState()
        shareButton.isEnabled = true
    }
    
    // MARK: - Toolbar
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet weak var subtaskVisibility: NSSwitch!
    @IBOutlet weak var linkVisibility: NSSwitch!
    @IBOutlet weak var performanceVisibility: NSSwitch!
    
    @IBOutlet weak var shareButton: NSToolbarItem!
    
    @IBAction func subtaskVisibilityDidChange(_ sender: NSSwitch) {
        let isOn = sender.state == .on
        view().modulesLayer?.showSubtask = isOn
        uiSettings.showSubtask = isOn
    }
    
    @IBAction func linkVisibilityDidChange(_ sender: NSSwitch) {
        let isOn = sender.state == .on
        view().modulesLayer?.showLinks = isOn
        uiSettings.showLinks = isOn
    }
    @IBAction func performanceVisibilityDidChange(_ sender: NSSwitch) {
        let isOn = sender.state == .on
        view().modulesLayer?.showPerformance = isOn
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
    let uiSettings = UISettings()
    let imageSaveService = ImageSaveService()
    
    func view() -> DetailView {
        view as! DetailView
    }
    
    // MARK: - Actions
    @IBAction func shareDidPressed(_ sender: Any) {
        imageSaveService.saveImage(
            name: "\(title ?? Date().description).png",
            view: view().contentView)
    }
   
    func clear() {
        view().removeLayer()
        shareButton.isEnabled = false
    }
    
    func resizeWindowHeight() {
        guard let window = view.window else { return }
        
        let contentSize = contentSize(appLayer: view().modulesLayer!)
        let newHeight = contentSize.height + view.safeAreaInsets.top
        let frame = CGRect(x: window.frame.minX,
                           y: max(0, window.frame.midY - newHeight/2),
                           width: window.frame.width,
                           height: newHeight)
        
        window.setFrame(frame, display: true, animate: true)
    }
                                  
    @objc func didClick(_ recognizer: NSClickGestureRecognizer) {
        let coordinate = recognizer.location(in: view().contentView)
        
        guard let event = view().modulesLayer?.event(at: coordinate)
        else { return }
              
        let events = event.steps
       
        guard events.count > 0 else {
            return // TODO: Give feedback
        }
        
        let child = controllerForDetailsPopover(events: events, title: event.taskName)
        
        child.preferredContentSize = CGSize(width: 1000, height: 500)
        present(child,
                asPopoverRelativeTo: CGRect(x: coordinate.x, y: coordinate.y, width: 10, height: 10),
                of: view().contentView,
                preferredEdge: .maxX,
                behavior: .transient)
    }
    
//    private func controllerForDetailsPopover(step: BuildStep) -> NSViewController {
//        let popover = NSStoryboard(name: "Main", bundle: nil)
//            .instantiateController(withIdentifier: "DetailPopover") as! DetailPopoverController
//        _ = popover.view
//        popover.text = step.description()
//        return popover
//    }
    
    private func controllerForDetailsPopover(events: [Event], title: String) -> NSViewController {
        let popover = NSStoryboard(name: "Details", bundle: nil)
            .instantiateController(withIdentifier: "data") as! DetailViewController
        _ = popover.view
        
        popover.show(events: events,
                     deps: [],
                     title: title,
                     embeddInWindow: false)
        return popover
    }
    
    private func contentSize(appLayer: AppLayer) -> CGSize {
        let contentHeight = appLayer.intrinsicContentSize.height
        
        let offset: CGFloat = 10
        
        return CGSize(width: max(500, view.frame.width - offset),
                      height: max(500, contentHeight)) // TODO: Define max as height of projects view
    }
    
    private func layoutModules() {
        guard let modulesLayer = view().modulesLayer else { return }
        
        let contentSize = contentSize(appLayer: modulesLayer)
        
        setModules(size: contentSize)
        
    }
    
    private func setModules(size: CGSize) {
        guard let modulesLayer = view().modulesLayer else { return }
        
        modulesLayer.updateWithoutAnimation {
            modulesLayer.frame = CGRect(
                x: 0, y: 0,
                width: size.width,
                height: size.height)
            modulesLayer.layoutIfNeeded()
        }
        
        view().contentView.frame = modulesLayer.bounds
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
        let coordinate = view().contentView.convert(
            event.locationInWindow,
            from: nil)
        
        view().modulesLayer?.highlightEvent(at: coordinate)
        view().modulesLayer?.drawConcurrency(at: coordinate)
        view().hudLayer?.drawConcurrency(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        view().modulesLayer?.clearHighlightedEvent()
        view().modulesLayer?.clearConcurrency()
        view().hudLayer?.clearConcurrency()
    }
}
