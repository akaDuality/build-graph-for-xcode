//
//  WindowController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 04.01.2022.
//

import AppKit
import BuildParser

class WindowController: NSWindowController {
    
    func window() -> MainWindow {
        window as! MainWindow
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window().setupToolbar(window!.toolbar!)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let filterSettingsController = segue.destinationController as? SettingsPopoverViewController {
            filterSettingsController.counter = splitViewController().detail.presenter.parser.makeCounter()
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
        projectsController?.selectNextFile()
    }
    
    @IBAction func nextProjectDidPress(_ sender: Any) {
        projectsController?.selectPreviousFile()
    }
    
    private var projectsController: ProjectsOutlineViewController? {
        // TODO: Rework
        splitViewController().projects.currentController as? ProjectsOutlineViewController
    }
    
    func splitViewController() -> SplitController {
        return self.contentViewController as! SplitController
    }
    
    @IBAction func refresh(_ sender: Any) {
        splitViewController().projectsPresenter.reloadProjetcs()
    }
}
