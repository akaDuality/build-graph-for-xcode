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
    
    @IBOutlet weak var cachedModulesCheckbox: NSButton!
    
    var settings: FilterSettings!
    weak var delegate: FilterSettingsDelegate?
    var counter: BuildStepCounter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Add settings restoration
        
        cachedModulesCheckbox.state = settings.showCached ? .on: .off
        
        for stepType in DetailStepType.allCases {
            let button = checkBox(for: stepType)
            
            if stepType.isCompilationStep() {
                compilationStackView.addArrangedSubview(button)
            } else {
                otherStackView.addArrangedSubview(button)
            }
        }
    }
    @IBAction func selectAllCompilationFlags(_ sender: Any) {
        setAllCheckbox(in: compilationStackView, to: .on)
    }
    
    @IBAction func deselectAllOtherFlags(_ sender: Any) {
        setAllCheckbox(in: otherStackView, to: .off)
    }
    
    private func setAllCheckbox(in stackView: NSStackView, to state: NSControl.StateValue) {
        for subview in stackView.arrangedSubviews {
            guard let checkbox = subview as? DetailStepCheckBox else { continue }
            
            checkbox.state = state
            updateSettings(stepType: checkbox.stepType, isOn: state == .on)
        }
        
        delegate?.didUpdateFilter(settings)
    }
    
    @IBAction func showCachedModulesDidChagne(_ sender: NSButton) {
        let isOn = sender.state == .on
        settings.showCached = isOn
        
        delegate?.didUpdateFilter(settings)
    }
    
    let durationFormatter = DurationFormatter()
    
    func checkBox(for type: DetailStepType) -> NSView {
        let button = DetailStepCheckBox(
            checkboxWithTitle: type.title,
            target: self,
            action: #selector(didCheck(sender:)))
        button.state = settings.allowedTypes.contains(type) ? .on: .off
        button.stepType = type
        
        let duration = counter.duration(of: type)
        let isZero = duration == 0
        button.isEnabled = !isZero
        
        let durationString = durationFormatter.string(from: duration)
        let label = NSTextField(string: durationString)
        label.alignment = .right
        label.isBordered = false
        label.isEnabled = false
        label.drawsBackground = false
        
        let stack = NSStackView(views: [button, label])
        
        return stack
    }
    
    @objc func didCheck(sender: DetailStepCheckBox) {
        let stepType = sender.stepType!
        let isOn = sender.state == .on
        
        updateSettings(stepType: stepType, isOn: isOn)
        
        delegate?.didUpdateFilter(settings)
    }
    
    func updateSettings(stepType: DetailStepType, isOn: Bool) {
        if isOn {
            settings.add(stepType: stepType)
        } else {
            settings.remove(stepType: stepType)
        }
    }
}

class DetailStepCheckBox: NSButton {
    var stepType: DetailStepType!
}
