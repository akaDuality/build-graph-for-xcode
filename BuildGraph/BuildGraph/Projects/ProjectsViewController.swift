//
//  ProjectsViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import Foundation
import AppKit
import BuildParser

protocol ProjectsViewControllerDelegate: AnyObject {
    func didSelect(project: ProjectReference)
}

class ProjectsViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    weak var delegate: ProjectsViewControllerDelegate?
    private let uiSettings = UISettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        reloadProjetcs()
        
        addContextMenu()
    }
    
    @objc func reloadProjetcs() {
        let pathFinder = ProjectsFinder(logOptions: .empty)
        projects = try! pathFinder.projects()
        
        if let selectedProject = uiSettings.selectedProject {
            select(project: selectedProject)
        }
    }
    
    func select(project: String) {
        guard let row = projects.firstIndex(where: { $0.name == project }) else {
            return
        }
        tableView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        delegate?.didSelect(project: projects[row])
    }
    
    var projects: [ProjectReference] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - Context menu
    
    private func addContextMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Show in Finder", action: #selector(showInFinder), keyEquivalent: "")
        tableView.menu = menu
    }
    
    @objc func showInFinder() {
        let project = projects[tableView.selectedRow]
        let path = project.activityLogURL.path
        
        let workspace = NSWorkspace.shared
        let selected = workspace.selectFile(path, inFileViewerRootedAtPath: "")
        if !selected {
            // TODO: Handle errors
//            showError()
        }
    }
}

extension ProjectsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        projects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = NSUserInterfaceItemIdentifier(rawValue: "ProjectCell")
        let cell = tableView.makeView(
            withIdentifier: id,
            owner: nil) as! ProjectCell
        
        cell.title = projects[row].name
        return cell
    }
}

extension ProjectsViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        let project = projects[tableView.selectedRow]
        delegate?.didSelect(project: project)
    }
}

class ProjectCell: NSTableCellView {
    @IBOutlet weak var titleLabel: NSTextField!
    
    var title: String = "" {
        didSet {
            titleLabel.stringValue = title
        }
    }
}
