//
//  MainWindow.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import AppKit
import BuildParser

class MainWindow: NSWindow {
    
    @IBOutlet weak var previousButton: NSToolbarItem!
    @IBOutlet weak var nextButton: NSToolbarItem!
    
    @IBOutlet weak var eventsButton: NSToolbarItem!
    @IBOutlet weak var sendImageToolbarItem: NSToolbarItem!
    
    func setupToolbar(_ toolbar: NSToolbar) {
        toolbar.insertItem(withItemIdentifier: .refresh, at: 0)
        toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 1)
        toolbar.insertItem(withItemIdentifier: .sidebarTrackingSeparator, at: 2)
        
        toolbar.sizeMode = .regular
        toolbar.displayMode = .iconOnly
        
        disableButtons()
    }
    
    func disableButtons() {
        sendImageToolbarItem.isEnabled = false
        eventsButton.isEnabled = false
    }
    
    func enableButtons() {
        sendImageToolbarItem.isEnabled = true
        eventsButton.isEnabled = true
    }
    
    func updateNavigationButtons(for project: ProjectReference) {
        previousButton.isEnabled = project.canIncreaseFile()
        nextButton.isEnabled = project.canDecreaseFile()
        
        subtitle = project.indexDescription
    }
    
    func resizeWindowHeight(to newHeight: CGFloat) {
        let frame = CGRect(x: frame.minX,
                           y: max(0, frame.midY - newHeight/2),
                           width: frame.width,
                           height: newHeight)
        
        setFrame(frame, display: true, animate: true)
    }
}
