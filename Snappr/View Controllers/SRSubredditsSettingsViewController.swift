//
//  SRSubredditsSettingsViewController.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 16/10/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Cocoa

class SRSubredditsSettingsViewController: NSViewController, NSTableViewDelegate {
    
    @IBOutlet var subredditsTable: NSTableView!

    init() {
        super.init(nibName: "SRSubredditsSettingsViewController", bundle: NSBundle.mainBundle())!
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: "SRSubredditsSettingsViewController", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subredditsTable.setDataSource(SRSubredditDataStore.sharedDatastore())
    }
    
}
