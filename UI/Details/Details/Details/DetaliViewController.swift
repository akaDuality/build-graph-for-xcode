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

public class DetailViewController: NSViewController {
    
    var zoomController: ZoomController!
    let mouseController = MouseContorller()
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        
        if embeddInWindow {
//            view().resizeWindowHeightIfPossible()
            view.window?.title = title!
        }
        
        mouseController.addMouseTracking(to: view())
        addClickRecognizers()
//        updateState()
        
        zoomController = ZoomController(
            scrollView: view().scrollView,
            delegate: self
        )
        
        zoomController.observeScrollChange()
    }
    
    public override func viewDidLayout() {
        super.viewDidLayout()
        
        view().resizeOnWindowChange()
    }
    
    private var embeddInWindow: Bool = true
    private var projectReference: ProjectReference?
    public func show(
        project: Project,
        title: String,
        embeddInWindow: Bool,
        projectReference: ProjectReference?,
        graphConfig: GraphConfig
    ) {
        self.title = title
        self.embeddInWindow = embeddInWindow
        self.projectReference = projectReference
        view().show(project: project, graphConfig: graphConfig)
    
//        updateState()
//        shareButton.isEnabled = true
    }
    
//    // MARK: - Toolbar
//    @IBOutlet var toolbar: NSToolbar!
//    @IBOutlet weak var subtaskVisibility: NSSwitch!
//    @IBOutlet weak var linkVisibility: NSSwitch!
//    @IBOutlet weak var performanceVisibility: NSSwitch!
//
//    @IBOutlet weak var shareButton: NSToolbarItem!
//
//    @IBAction func subtaskVisibilityDidChange(_ sender: NSSwitch) {
//        let isOn = sender.state == .on
//        view().modulesLayer?.showSubtask = isOn
//        uiSettings.showSubtask = isOn
//    }
//
//    @IBAction func linkVisibilityDidChange(_ sender: NSSwitch) {
//        let isOn = sender.state == .on
//        view().modulesLayer?.showLinks = isOn
//        uiSettings.showLinks = isOn
//    }
//    @IBAction func performanceVisibilityDidChange(_ sender: NSSwitch) {
//        let isOn = sender.state == .on
//        view().modulesLayer?.showPerformance = isOn
//        uiSettings.showPerformance = isOn
//    }
    
//    private func updateState() {
//        subtaskVisibility       .state = .on//uiSettings.showSubtask ? .on: .off
//        linkVisibility          .state = .on//uiSettings.showLinks ? .on: .off
//        performanceVisibility   .state = uiSettings.showPerformance ? .on: .off
//
//        subtaskVisibilityDidChange(subtaskVisibility)
//        linkVisibilityDidChange(linkVisibility)
//        performanceVisibilityDidChange(performanceVisibility)
//    }
    
    // MARK: - Content
//    let uiSettings = UISettings()
    
    public func view() -> DetailView {
        view as! DetailView
    }
    
    // MARK: - Actions
    @IBAction func shareDidPressed(_ sender: Any) {
        shareImage()
    }
    
    public func shareImage() {
        FileLocationSelector()
            .requestLocation(
                project: projectReference,
                title: title!,
                fileExtension: XcodeBuildSnapshot.bgbuildsnapshot)
        { url in
            
//            ImageSaveService().saveImage(
//                url: url,
//                view: self.view().contentView)
            
            SnapshotSaveService().save(
                project: self.projectReference!,
                to: url)
        }
    }
   
    func clear() {
        view().removeLayer()
//        shareButton.isEnabled = false
    }
    
    // MARK: - Mouse
    private func addClickRecognizers() {
        let leftClickRecognizer = NSClickGestureRecognizer(
            target: self,
            action: #selector(didLeftClick(_:))
        )
        view().contentView.addGestureRecognizer(leftClickRecognizer)
        
//        let rightClickRecognizer = NSClickGestureRecognizer(
//            target: self,
//            action: #selector(didRightClick(_:))
//        )
//        rightClickRecognizer.buttonMask = 0x2
//        view().contentView.addGestureRecognizer(rightClickRecognizer)
    }
                                  
    @objc func didLeftClick(_ recognizer: NSClickGestureRecognizer) {
        guard !isPopoverPresented else { return } // Click will dismith previous one
        
        let coordinate = recognizer.location(in: view().contentView)
        
        guard let event = view().modulesLayer?.event(at: coordinate) else { return }
              
        let events = event.steps
       
        guard events.count > 0 else {
            return // TODO: Give feedback
        }
        
        presentPopover(events: events, title: event.taskName, coordinate: coordinate)
    }
    
    @objc func didRightClick(_ recognizer: NSClickGestureRecognizer) {
        let coordinate = recognizer.location(in: view().contentView)
        
        view().modulesLayer?.selectEvent(at: coordinate)
    }
    
    private func presentPopover(events: [Event], title: String, coordinate: NSPoint) {
        let child = controllerForDetailsPopover(events: events, title: title)
        
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
    
    public func search(text: String?) {
        view().modulesLayer?.highlightEvent(with: text)
    }
    
    private func controllerForDetailsPopover(events: [Event], title: String) -> NSViewController {
        let popover = NSStoryboard(name: "Details", bundle: Bundle(for: type(of: self)))
            .instantiateController(withIdentifier: "data") as! DetailViewController
        _ = popover.view
        
        popover.show(project: Project(events: events, relativeBuildStart: 0),
                     title: title,
                     embeddInWindow: false,
                     projectReference: nil,
                     graphConfig: view().graphConfig!)
        return popover
    }
    
    public override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Zoom

    @IBAction func zoomIn(_ sender: Any) {
        zoomController.zoomIn()
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        zoomController.zoomOut()
    }
}

extension DetailViewController: ZoomDelegate {
    func didZoom(to magnification: CGFloat) {    
        view().hudView.hudLayer?.scale(to: magnification)
    }
}

extension CALayer {
    func updateScale(to scale: CGFloat) {
        contentsScale = scale
        
        updateSublayers(to: scale)
    }
    
    private func updateSublayers(to scale: CGFloat) {
        for layer in sublayers ?? [] {
            layer.updateScale(to: scale)
        }
    }
}
