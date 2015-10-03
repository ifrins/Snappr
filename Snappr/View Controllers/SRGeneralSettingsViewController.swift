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

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
    }
    
}
