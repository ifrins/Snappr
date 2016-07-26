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
    @IBOutlet var addModalWindow: NSWindow!
    @IBOutlet var newSubredditField: NSTextField!

    init() {
        super.init(nibName: "SRSubredditsSettingsViewController", bundle: NSBundle.mainBundle())!
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: "SRSubredditsSettingsViewController", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subredditsTable.dataSource = SRSubredditDataStore.sharedDatastore()
    }
    
    @IBAction func segmentControlAction(sender: NSSegmentedControl) {
        let selectedSegment = sender.selectedSegment
        
        switch selectedSegment {
        case 0:
            view.window?.beginSheet(addModalWindow, completionHandler: nil)
        case 1:
            removeSelectedSubreddit()
        default:
            return
        }
    }
        
    @IBAction func dismissSubredditModal(sender: AnyObject) {
        view.window?.endSheet(addModalWindow)
    }

    
    @IBAction func addSubreddit(sender: AnyObject) {
        let subreddit = newSubredditField.stringValue
        
        if subreddit.characters.count == 0 {
            return
        }
        
        SRSubredditDataStore.sharedDatastore().addSubreddit(subreddit)
        
        view.window?.endSheet(addModalWindow)
        subredditsTable.reloadData()
    }

    private func removeSelectedSubreddit() {
        let selectedRow = subredditsTable.selectedRow
        SRSubredditDataStore.sharedDatastore().removeSubreddit(selectedRow)
        subredditsTable.reloadData()
    }

}
