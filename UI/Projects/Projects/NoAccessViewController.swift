//
//  NoAccessViewController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 06.03.2022.
//

import Foundation
import AppKit

class NoAccessViewController: NSViewController {
    weak var delegate: NoProjectsDelegate?
    
    @IBAction func changeDerivedDataDidPress(_ sender: Any) {
        delegate?.requestAccessAndReloadProjects()
    }
}
