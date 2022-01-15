//
//  WindowController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 04.01.2022.
//

import AppKit

class MainWindow: NSWindow {
   
    @IBOutlet weak var previousButton: NSToolbarItem!
    @IBOutlet weak var nextButton: NSToolbarItem!
    
    @IBOutlet weak var sendImageToolbarItem: NSToolbarItem!
    
    func setupToolbar(_ toolbar: NSToolbar) {
        toolbar.insertItem(withItemIdentifier: .refresh, at: 0)
        toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 1)
        toolbar.insertItem(withItemIdentifier: .sidebarTrackingSeparator, at: 2)
        
        toolbar.sizeMode = .regular
        toolbar.displayMode = .iconOnly
        
        sendImageToolbarItem.isEnabled = false
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
        splitViewController().detail.previousFile()
    }
    
    @IBAction func nextProjectDidPress(_ sender: Any) {
        splitViewController().detail.nextFile()
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
            refresh.action = #selector(splitViewController().projects.reloadProjetcs)
            return refresh
        default:
            fatalError()
        }
    }
}

extension NSToolbarItem.Identifier {
    static let refresh = Self(rawValue: "Refresh")
}
