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
    func didSelect(project: String)
}

class ProjectsViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    weak var delegate: ProjectsViewControllerDelegate?
    private let uiSettings = UISettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let pathFinder = PathFinder(logOptions: .empty)
        projects = try! pathFinder.projects()
        
        if let selectedProject = uiSettings.selectedProject {
            select(project: selectedProject)
        }
    }
    
    func select(project: String) {
        guard let row = projects.firstIndex(of: project) else {
            return
        }
        tableView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
        delegate?.didSelect(project: project)
    }
    
    @IBAction func refreshDidPressed(_ sender: Any) {
        
    }
    var projects: [String] = [] {
        didSet {
            tableView.reloadData()
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
        
        cell.title = projects[row]
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
