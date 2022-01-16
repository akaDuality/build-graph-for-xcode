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

class HUDScrollView: NSScrollView {
    var hudLayer: HUDLayer?
    
//    override func layout() {
//        super.layout()
//
//        hudLayer?.frame = bounds
//    }
    
    func observeScrollChange() {
        
        contentView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didScrollContent),
                                               name: NSView.boundsDidChangeNotification,
                                               object: nil)
    }
    
    @objc func didScrollContent() {
        hudLayer?.updateWithoutAnimation {
            hudLayer?.frame = contentView.bounds.offsetBy(dx: 0, dy: 52) // TODO: Remove hardcode
        }
    }
}

class DetailView: NSView {
    var modulesLayer: AppLayer?
    var hudLayer: HUDLayer?
    
    @IBOutlet weak var scrollView: HUDScrollView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    let contentView = FlippedView()
    
    func showEvents(events: [Event]) {
        let scale = NSScreen.main!.backingScaleFactor
        
        modulesLayer = AppLayer(
            events: events,
            scale: scale)
        
        hudLayer = HUDLayer(events: events, scale: scale)
        needsLayout = true
        
        contentView.wantsLayer = true
        contentView.layer?.addSublayer(modulesLayer!)
        
        scrollView.documentView = contentView
        scrollView.allowsMagnification = true
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = .zero
        
        scrollView.hudLayer = hudLayer
        modulesLayer?.addSublayer(hudLayer!)
        
        layoutModules() // calc intrinsic content size
        
        scrollView.observeScrollChange()
    }
    
    override func layout() {
        super.layout()
        
        hudLayer?.frame = bounds
    }
    
    override func updateLayer() {
        super.updateLayer()
        
        modulesLayer?.setNeedsLayout()
        hudLayer?.setNeedsLayout()
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        
        guard let events = modulesLayer?.events else {
            return
        }
        
        removeLayer()
        showEvents(events: events)
        updateSettings()
    }
    
    func removeLayer() {
        for layer in (contentView.layer?.sublayers ?? []) {
            layer.removeFromSuperlayer()
        }
        
        modulesLayer = nil
    }
    
    // TODO: Move setting to layer initialization
    let uiSettings = UISettings()
    private func updateSettings() {
        modulesLayer?.showPerformance = uiSettings.showPerformance
        modulesLayer?.showLinks = uiSettings.showLinks
        modulesLayer?.showSubtask = uiSettings.showSubtask
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
    
    func resizeWindowHeight() {
        guard let window = window else { return }
        
        let contentSize = contentSize(appLayer: modulesLayer!)
        let newHeight = contentSize.height + safeAreaInsets.top
        let frame = CGRect(x: window.frame.minX,
                           y: max(0, window.frame.midY - newHeight/2),
                           width: window.frame.width,
                           height: newHeight)
        
        window.setFrame(frame, display: true, animate: true)
    }
}


class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            true
        }
    }
}
