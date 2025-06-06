//
//  ProjectsOutlineViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 15.01.2022.
//

import AppKit
import BuildParser

public enum SelectSource {
    case navigationButtons(project: ProjectReference)
    case leftPanel(project: ProjectReference, lastBuildIndex: Int?)
}

protocol ProjectsListDatasource {
    var projects: [ProjectReference] { get }
    
    func select(from: SelectSource)
    func changeBuild(from: SelectSource)
    func shouldSelectProject(project: ProjectReference) -> Bool
    
    func description(for url: URL) -> String
    func tooltip(for url: URL) -> String
}

public class ProjectsOutlineViewController: NSViewController {
    
    // Dependencies
    var presenter: ProjectsListDatasource!
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view().outlineView.dataSource = self
        view().outlineView.delegate = self
    }
    
    public override func viewWillAppear() {
        super.viewWillAppear()

        addContextMenu()
    }
    
    func view() -> ProjectsOutlineView {
        view as! ProjectsOutlineView
    }
    
    // MARK: - Context Menu
    
    private func addContextMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: NSLocalizedString("Show in Finder", comment: ""),
                     action: #selector(showInFinder), keyEquivalent: "")
        view().outlineView.menu = menu
    }
    
    @objc func showInFinder() {
        guard let url = view().selectedProject()?.currentActivityLog else {
            return
            // TODO: Log error
        }
        
        openURL(url)
    }

    private func openURL(_ url: URL) {
        let workspace = NSWorkspace.shared
        let selected = workspace.selectFile(url.path, inFileViewerRootedAtPath: "")
        if !selected {
//            TODO: Handle errors
//            showError()
        }
    }
}

// MARK: - NSOutlineViewDataSource

extension ProjectsOutlineViewController: NSOutlineViewDataSource {
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let project = item as? ProjectReference {
            return project.activityLogURL.count
        } else {
            return presenter.projects.count
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let project = item as? ProjectReference {
            return project.activityLogURL[index]
        } else {
            return presenter.projects[index]
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let project = item as? ProjectReference {
            return project.activityLogURL.count > 0
        } else {
            return false
        }
    }
}

// MARK: - NSOutlineViewDelegate

extension ProjectsOutlineViewController: NSOutlineViewDelegate {
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("ProjectCell")
        
        let view = outlineView.makeView(withIdentifier: id, owner: self) as? NSTableCellView
        
        if let project = item as? ProjectReference {
            view?.textField?.stringValue = project.name
        } else if let url = item as? URL {
            view?.textField?.stringValue = presenter.description(for: url)
            view?.toolTip = presenter.tooltip(for: url)
        }
        
        return view
    }
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        if let project = outlineView.item(atRow: outlineView.selectedRow) as? ProjectReference {
            presenter.select(from: .leftPanel(project: project, lastBuildIndex: nil))
        } else if let url = outlineView.item(atRow: outlineView.selectedRow) as? URL,
                  let project = outlineView.parent(forItem: url) as? ProjectReference {
            
            let previousIndex = project.currentActivityLogIndex
            project.currentActivityLogIndex = outlineView.childIndex(forItem: url)
            presenter.changeBuild(from: .leftPanel(project: project, lastBuildIndex: previousIndex))
        }
    }
    
    /// Разворачивая проект выделяю текущий УРЛ
    public func outlineViewItemDidExpand(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        if let project = outlineView.item(atRow: outlineView.selectedRow) as? ProjectReference {
            view().select(url: project.currentActivityLog)
        }
    }
    
    /// Сворачивая  выделяю текущий проект
    public func outlineViewItemDidCollapse(_ notification: Notification) {
        guard let _ = notification.object as? NSOutlineView else { return }
        
        if let project = notification.userInfo?["NSObject"] as? ProjectReference,
           presenter.shouldSelectProject(project: project) {
            view().select(project: project)
        }
    }
}

// MARK: - ProjectsOutlineViewController

extension ProjectsOutlineViewController {
    
    func select(project: ProjectReference) {
        view().select(project: project)
    }
    
    public func selectNextFile() {
        changeSelection { project in
            project.selectNextFile()
        }
    }
    
    public func selectPreviousFile() {
        changeSelection { project in
            project.selectPreviousFile()
        }
    }
    
    func changeSelection(_ block: (ProjectReference) -> Void) {
        guard let project = view().selectedProject() else { return }
        
        block(project)
        presenter.select(from: .navigationButtons(project: project))
            
        view().select(url: project.currentActivityLog)
    }
}

// MARK: - ProjectsOutlineView

class ProjectsOutlineView: NSView {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    func selectedProject() -> ProjectReference? {
        if let url = outlineView.item(atRow: outlineView.selectedRow) as? URL,
           let project = outlineView.parent(forItem: url) as? ProjectReference {
            return project
        } else if let project = outlineView.item(atRow: outlineView.selectedRow) as? ProjectReference {
            return project
        }
            
        return nil
    }
    
    func select(url: URL) {
        select(url)
    }
    
    func select(project: ProjectReference) {
        select(project)
    }
    
    private func select(_ any: Any) {
        let row = outlineView.row(forItem: any)
        outlineView.selectRowIndexes(IndexSet(integer: row),
                                     byExtendingSelection: false)
    }
}
