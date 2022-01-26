//
//  DetailViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Cocoa
import BuildParser
import GraphParser
import XCLogParser

class DetailViewController: NSViewController {
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if embeddInWindow {
//            view.window?.toolbar = toolbar
            view().resizeWindowHeight()
            view.window?.title = title!
        }
        
        addMouseTracking()
        view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(didClick(_:))))
        updateState()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        view().resizeOnWindowChange()
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
        subtaskVisibility       .state = .on//uiSettings.showSubtask ? .on: .off
        linkVisibility          .state = .on//uiSettings.showLinks ? .on: .off
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
        shareImage()
    }
    
    func shareImage() {
        imageSaveService.saveImage(
            name: "\(title ?? Date().description).png",
            view: view().contentView)
    }
   
    func clear() {
        view().removeLayer()
        shareButton.isEnabled = false
    }
                                  
    @objc func didClick(_ recognizer: NSClickGestureRecognizer) {
        guard !isPopoverPresented else { return } // Click will dismith previous one
        
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
    
    private var isPopoverPresented: Bool {
        presentedViewControllers?.contains(where: { controller in
            controller is DetailViewController
        }) ?? false 
    }
    
    func search(text: String?) {
        view().modulesLayer?.highlightEvent(with: text)
    }
    
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
