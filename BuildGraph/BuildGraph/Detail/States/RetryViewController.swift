//
//  RetryViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 03.01.2022.
//

import AppKit

class RetryViewController: NSViewController {
    
    @IBOutlet weak var titleLabel: NSTextField!
    
    var showNonCompilationEvents: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func showNonCompilationEventsDidPressed(_ sender: Any) {
        showNonCompilationEvents()
    }
}
