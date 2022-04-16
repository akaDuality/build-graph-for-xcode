//
//  DetailView.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 02.01.2022.
//

import Cocoa
import BuildParser
import GraphParser
import XCLogParser

public protocol GraphConfig {
    var textSize: Int { get }
    var showLegend: Bool { get }
}

public class DetailView: NSView {
    var modulesLayer: AppLayer?
    
    public var showLegend: Bool = true {
        didSet {
            hudView.hudLayer?.legendIsHidden = !showLegend
        }
    }
    @IBOutlet weak var hudView: HUDView!
    @IBOutlet weak var scrollView: HUDScrollView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var zoomInButton: NSButton!
    @IBOutlet weak var zoomOutButton: NSButton!
    
    var contentView = FlippedView()
    
    var project: Project?
    var graphConfig: GraphConfig?
    
    public func show(project: Project, graphConfig: GraphConfig) {
        self.project = project
        self.graphConfig = graphConfig
        let scale = NSScreen.main!.backingScaleFactor
        
        modulesLayer = AppLayer(
            events: project.events,
            relativeBuildStart: project.relativeBuildStart,
            fontSize: CGFloat(graphConfig.textSize), // TODO: Move to parameters?
            scale: scale)
        
        needsLayout = true
        
        contentView = FlippedView()
        contentView.wantsLayer = true
        contentView.layer?.masksToBounds = false
        contentView.layer?.addSublayer(modulesLayer!)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = .zero
        
        hudView.setup(duration: project.events.duration(),
                      legendIsHidden: !graphConfig.showLegend, // TODO: Move to parameters?
                      scale: scale)
        scrollView.hudLayer = hudView.hudLayer
//        modulesLayer?.addSublayer(hudLayer!)
        
        layoutModules() // calc intrinsic content size
        layoutSubtreeIfNeeded()
    }
    
    public override func updateLayer() {
        super.updateLayer()
        
        modulesLayer?.setNeedsLayout()
    }
    
    public override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        
        recreateHierarchy()
    }
    
    public func recreateHierarchy() {
        guard
            let project = project,
            let graphConfig = graphConfig
        else { return }
        
        removeLayer()
        show(project: project, graphConfig: graphConfig)
        updateSettings()
    }
    
    func removeLayer() {
        for layer in (contentView.layer?.sublayers ?? []) {
            layer.removeFromSuperlayer()
        }
        
        modulesLayer = nil
    }
    
    // TODO: Move setting to layer initialization
    private func updateSettings() {
        modulesLayer?.showPerformance = false
        modulesLayer?.showLinks = true
        modulesLayer?.showSubtask = true
    }
    
    private func contentSize(appLayer: AppLayer) -> CGSize {
        let contentHeight = appLayer.intrinsicContentSize.height
        
        let offset: CGFloat = 10
        
        return CGSize(width: max(500, frame.width - offset),
                      height: max(500, contentHeight)) // TODO: Define max as height of projects view
    }
    
    private func layoutModules() {
        let contentSize = contentSize(appLayer: modulesLayer!)
        
        setModules(size: contentSize)
    }
    
    func resizeOnWindowChange() {
        setModules(
            size: CGSize(
                width: bounds.width,
                height: max(
                    bounds.size.height,
                    contentSize(appLayer: modulesLayer!).height
                )
            )
        )
    }
    
    private func setModules(size: CGSize) {
        modulesLayer!.updateWithoutAnimation {
            modulesLayer!.frame = CGRect(
                x: 0, y: 0,
                width: size.width,
                height: size.height)
            modulesLayer!.layoutIfNeeded()
        }
        
        contentView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: size.width,
                                   height: size.height - 52)
    }
    
//    func resizeWindowHeightIfPossible() {
//        let isFullscreen = NSApplication.shared.presentationOptions.contains(.fullScreen)
//        guard !isFullscreen else { return }
//        guard let window = window as? MainWindow else { return }
//
//        let contentSize = contentSize(appLayer: modulesLayer!)
//        let newHeight = contentSize.height + safeAreaInsets.top
//
//        window.resizeWindowHeight(to: newHeight)
//    }
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}
