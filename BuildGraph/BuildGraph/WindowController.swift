//
//  WindowController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 04.01.2022.
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
}

class WindowController: NSWindowController {
    
    func window() -> MainWindow {
        window as! MainWindow
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window!.toolbar!.delegate = self
        window().setupToolbar(window!.toolbar!)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let filterSettingsController = segue.destinationController as? SettingsPopoverViewController {
            filterSettingsController.delegate = splitViewController()
            filterSettingsController.settings = splitViewController().filter
        }
    }
    
    @IBAction func makeScreenshotOfGraph(_ sender: Any) {
        guard let detailController = splitViewController().detail.currentController as? DetailViewController else {
            return
        }
        
        detailController.shareImage()
    }
    
    @IBAction func searchDidChange(_ sender: NSSearchField) {
        let text = sender.stringValue
     
        guard let detailController = splitViewController().detail.currentController as? DetailViewController else { return }
        
        detailController.search(text: text)
    }
    
    @IBAction func previousProjectDidPress(_ sender: Any) {
        splitViewController().projects.selectNextFile()
    }
    
    @IBAction func nextProjectDidPress(_ sender: Any) {
        splitViewController().projects.selectPreviousFile()
    }
    
    func splitViewController() -> SplitController {
        return self.contentViewController as! SplitController
    }
}

extension WindowController: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .refresh:
            let refresh = NSToolbarItem(itemIdentifier: itemIdentifier)
            refresh.image = NSImage(systemSymbolName: "arrow.clockwise",
                                    accessibilityDescription: NSLocalizedString("Refresh projects", comment: "Toolbar button"))
            refresh.label = NSLocalizedString("Refresh", comment: "Toolbar button")
            refresh.target = splitViewController().projects
            refresh.action = #selector(splitViewController().projects.presenter.reloadProjetcs)
            refresh.isEnabled = true
            return refresh
        default:
            fatalError()
        }
    }
    
    @objc func refresh() {
        splitViewController().projects.presenter.reloadProjetcs()
    }
}

extension NSToolbarItem.Identifier {
    static let refresh = Self(rawValue: "Refresh")
}
