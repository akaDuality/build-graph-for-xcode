//
//  WindowController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 04.01.2022.
//

import AppKit

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        setupToolbar(window!.toolbar!)
    }
    
    func setupToolbar(_ toolbar: NSToolbar) {
        toolbar.delegate = self
        
        toolbar.insertItem(withItemIdentifier: .refresh, at: 0)
        toolbar.insertItem(withItemIdentifier: .toggleSidebar, at: 1)
        toolbar.insertItem(withItemIdentifier: .sidebarTrackingSeparator, at: 2)
        
        toolbar.sizeMode = .regular
        toolbar.displayMode = .iconOnly
    }
    
    private func splitViewController() -> SplitController {
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
