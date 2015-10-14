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
        
        let spacesChanging = SRSettings.changeAllSpaces
        setSpaceChanging(spacesChanging)
    }
    
    @IBAction func updateLabel(sender: AnyObject) {
        let freq = timeIntervalForSlider(frequencySlider.integerValue)
        setTimeLabel(freq)
        
        SRSettings.refreshFrequency = freq
    }
    
    private func timeIntervalForSlider(interval: Int) -> NSTimeInterval {
        var steps = (interval / 5) + 1
        
        if steps > 5 {
            steps += 5
        }
        
        if steps > 16 {
            steps += 9
        }
        
        return NSTimeInterval(steps * 3600)
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
