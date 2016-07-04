//
//  SRGeneralSettingsViewController.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 1/10/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Cocoa

class SRGeneralSettingsViewController: NSViewController {
    
    @IBOutlet var frequencySlider: NSSlider!
    @IBOutlet var frequencyLabel: NSTextField!
    @IBOutlet var spacesCheckbox: NSButton!

    init() {
        super.init(nibName: "SRGeneralSettingsViewController", bundle: NSBundle.mainBundle())!
    }

    required init?(coder: NSCoder) {
        super.init(nibName: "SRGeneralSettingsViewController", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshFrequency = SRSettings.refreshFrequency
        setTimeLabel(refreshFrequency)
        setTimeSlider(refreshFrequency)
        
        let spacesChanging = SRSettings.changeAllSpaces
        setSpaceChanging(spacesChanging)
    }
    
    @IBAction func updateLabel(sender: AnyObject) {
        let freq = timeIntervalForSlider(frequencySlider.integerValue)
        setTimeLabel(freq)
        
        SRSettings.refreshFrequency = freq
    }
    
    @IBAction func updateSpacesCheckbox(sender: AnyObject) {
        if spacesCheckbox.state == NSOnState {
            SRSettings.changeAllSpaces = true
        } else {
            SRSettings.changeAllSpaces = true
        }
    }
    
    private func setTimeSlider(timeInterval: NSTimeInterval) {
        let step = sliderPositionFromTimeInterval(timeInterval)
        let closest = frequencySlider.closestTickMarkValueToValue(step)
        frequencySlider.doubleValue = closest
    }
    
    private func timeIntervalForSlider(interval: Int) -> NSTimeInterval {
        let steps = (interval + 1)
        
        return NSTimeInterval(steps * 3600)
    }
    
    private func sliderPositionFromTimeInterval(timeInterval: NSTimeInterval) -> Double {
        let position = (timeInterval / 3600 / 22) - 1
        return position
    }
    
    private func setTimeLabel(seconds: NSTimeInterval) {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Short
        formatter.allowedUnits = .Hour
        
        let formatted = formatter.stringFromTimeInterval(seconds)
        
        if formatted != nil {
            frequencyLabel.stringValue = formatted!
        }
    }
    
    private func setSpaceChanging(changing: Bool) {
        if changing {
            spacesCheckbox.state = NSOnState
        } else {
            spacesCheckbox.state = NSOffState
        }
    }
    
}
