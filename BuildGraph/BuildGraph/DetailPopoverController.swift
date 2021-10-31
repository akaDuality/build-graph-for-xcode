//
//  DetailPopoverController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 31.10.2021.
//

import Foundation
import AppKit

class DetailPopoverController: NSViewController {
    @IBOutlet weak var textField: NSTextField!
    
    var text: String = "" {
        didSet {
            textField.stringValue = text
        }
    }
}
