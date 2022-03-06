//
//  NoProjectsViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import Foundation
import AppKit
import BuildParser

protocol NoProjectsDelegate: AnyObject {
    func requestAccessAndReloadProjects()
    func reloadProjetcs()
}

class NoProjectsViewController: NSViewController {
    
    weak var delegate: NoProjectsDelegate?
    
    @IBAction func refreshDidPress(_ sender: Any) {
        delegate?.reloadProjetcs()
    }
    
    @IBAction func changeDerivedDataDidPress(_ sender: Any) {
        delegate?.requestAccessAndReloadProjects()
    }
    
    func view() -> NoProjectsView {
        view as! NoProjectsView
    }
}

class NoProjectsView: NSView {
    var derivedData: URL! {
        didSet {
            derivedDataPath = derivedData.path
        }
    }
    
    fileprivate var derivedDataPath: String! {
        didSet {
            pathLabel.stringValue = derivedDataPath
        }
    }
    
    @IBOutlet weak var pathLabel: NSTextField!
}
