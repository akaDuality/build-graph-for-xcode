//
//  SettingsPopoverViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 16.01.2022.
//

import AppKit
import XCLogParser
import BuildParser

protocol FilterSettingsDelegate: AnyObject {
    func didUpdateFilter(_ filterSettings: FilterSettings)
}

class SettingsPopoverViewController: NSViewController {
    @IBOutlet weak var compilationStackView: NSStackView!
    @IBOutlet weak var otherStackView: NSStackView!
    
    var settings: FilterSettings!
    weak var delegate: FilterSettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Add settings restoration
        
        for stepType in DetailStepType.allCases {
            let button = checkBox(for: stepType)
            
            if stepType.isCompilationStep() {
                compilationStackView.addArrangedSubview(button)
            } else {
                otherStackView.addArrangedSubview(button)
            }
        }
    }
    
    @IBAction func showCachedModulesDidChagne(_ sender: NSButton) {
        let isOn = sender.state == .on
        settings.showCached = isOn
        
        delegate?.didUpdateFilter(settings)
    }
    
    func checkBox(for type: DetailStepType) -> NSButton {
        let button = DetailStepCheckBox(
            checkboxWithTitle: type.title,
            target: self,
            action: #selector(didCheck(sender:)))
        
        button.state = settings.allowedTypes.contains(type) ? .on: .off
        button.stepType = type
        
        return button
    }
    
    @objc func didCheck(sender: DetailStepCheckBox) {
        let stepType = sender.stepType!
        let isOn = sender.state == .on
        
        if isOn {
            settings.add(stepType: stepType)
        } else {
            settings.remove(stepType: stepType)
        }
        
        delegate?.didUpdateFilter(settings)
    }
}

class DetailStepCheckBox: NSButton {
    var stepType: DetailStepType!
}

extension DetailStepType {
    var title: String {
        switch self {
        // Compile
        case .cCompilation: return "C"
             
        case .swiftCompilation: return "Swift"
            
        case .compileAssetsCatalog: return "Asset catalogs"
            
        case .compileStoryboard: return "Storyboard"
            
        case .XIBCompilation: return "Xib"
            
        case .swiftAggregatedCompilation: return "Swift Aggregated Compilation"
           
        // Non-compile
        case .scriptExecution: return "Script execution"
            
        case .createStaticLibrary: return "Create static library"
            
        case .linker: return "Linker"
            
        case .copySwiftLibs: return "Copy Swift Libs"
            
        case .writeAuxiliaryFile: return "Write auxiliary file"
            
        case .linkStoryboards: return "Link storyboards"
            
        case .copyResourceFile: return "Copy resourve files"
            
        case .mergeSwiftModule: return "Merge Swift module"
            
        case .precompileBridgingHeader: return "Precompile Bridging Header"
            
        case .other: return "Other"
            
        case .none: return "Unknown"
        
        }
    }
}
