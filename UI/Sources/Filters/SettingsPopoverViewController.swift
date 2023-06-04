//
//  SettingsPopoverViewController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 16.01.2022.
//

import AppKit
import XCLogParser
import BuildParser

public protocol FilterSettingsDelegate: AnyObject {
    func didUpdateFilter(_ filterSettings: FilterSettings)
    func didUpdateUISettings()
}

public class SettingsPopoverViewController: NSViewController {
    public static func load(
        with delegate: FilterSettingsDelegate,
        counter: BuildStepCounter
    ) -> NSViewController {
        let storyboard = NSStoryboard(
            name: "Settings",
            bundle: Bundle.module)
        
        let settingsController = storyboard.instantiateController(
            withIdentifier: "Settings") as! SettingsPopoverViewController
        
        settingsController.delegate = delegate
        settingsController.setup(counter: counter) // TODO: Refactor
        
        return settingsController
    }
    
    @IBOutlet weak var compilationStackView: NSStackView!
    @IBOutlet weak var otherStackView: NSStackView!
    @IBOutlet weak var formatStackView: NSStackView!
    
    // MARK: Cache
    @IBOutlet weak var cachedModuleSegmentedControl: NSSegmentedControl!
    
    @IBAction func cachedModuleSegmentedControlDidChange(_ sender: Any) {
        settings.cacheVisibility = .init(rawValue: cachedModuleSegmentedControl.indexOfSelectedItem)!
        delegate?.didUpdateFilter(settings)
    }
    
    // MARK: -
    let settings = FilterSettings.shared
    weak var delegate: FilterSettingsDelegate?
    private var counter: BuildStepCounter!
    
    func setup(counter: BuildStepCounter) {
        _ = view // Load view from storyboard
        self.counter = counter
        cachedModuleSegmentedControl.selectedSegment = settings.cacheVisibility.rawValue
        
        for stepType in DetailStepType.allCases {
            let button = checkBox(for: stepType)
            
            if stepType.isCompilationStep() {
                compilationStackView.addArrangedSubview(button)
            } else {
                otherStackView.addArrangedSubview(button)
            }
        }
        
        setupTextSize()
        showLegend.state = UISettings().showLegend ? .on: .off
        
        formatStackView.setCustomSpacing(24, after: textSizeSlider)
        textSizeSlider.isContinuous = true
    }
    
    @IBAction func selectAllCompilationFlags(_ sender: Any) {
        setAllCheckbox(in: compilationStackView, to: .on)
    }
    
    @IBAction func deselectAllOtherFlags(_ sender: Any) {
        setAllCheckbox(in: otherStackView, to: .off)
    }
    
    private func setAllCheckbox(in stackView: NSStackView, to state: NSControl.StateValue) {
        for subview in stackView.arrangedSubviews {
            guard let checkbox = subview.subviews.first as? DetailStepCheckBox else { continue }
            
            checkbox.state = state
            updateSettings(stepType: checkbox.stepType, isOn: state == .on)
        }
        
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
    
    // MARK: Format
    @IBAction func showLegendDidChanged(_ sender: NSButton) {
        UISettings().showLegend = sender.state == .on
        
        delegate?.didUpdateUISettings()
    }
    
    @IBOutlet weak var showLegend: NSButton!
    
    private func setupTextSize() {
        textSizeSlider.integerValue = UISettings().textSize
        textSizeLabel.stringValue = "Font size: \(UISettings().textSize)"
    }
    
    @IBAction func textSizeDidChange(_ sender: NSSlider) {
        UISettings().textSize = sender.integerValue
        
        setupTextSize()
        
        delegate?.didUpdateUISettings()
    }
    
//    @IBAction func textSizeDidChange(_ sender: NSStepper) {
//        UISettings().textSize = sender.integerValue
//
//        setupTextSize()
//
//        delegate?.didUpdateUISettings()
//    }
    
    @IBOutlet weak var textSizeLabel: NSTextField!
    @IBOutlet weak var textSizeSlider: NSSlider!
}

class DetailStepCheckBox: NSButton {
    var stepType: DetailStepType!
}
