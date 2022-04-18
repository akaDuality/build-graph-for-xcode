//
//  LoadingViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 03.01.2022.
//

import AppKit

class LoadingViewController: NSViewController {
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressIndicator.startAnimation(self)
    }
}
