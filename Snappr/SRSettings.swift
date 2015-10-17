//
//  SRSettings.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 4/10/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Cocoa

class SRSettings: NSObject {
    class var imagesPath: String {
        get {
            return getImagesPath()
        }
    }
    
    class var settingsPath: String {
        get {
            return getSettingsFilePath();
        }
    }
    
    class var lastUpdated: NSDate {
        get {
            return getLastUpdatedImage()
        }
        
        set {
            setLastUpdatedImage(newValue)
        }
    }
    
    class var refreshFrequency: NSTimeInterval {
        get {
            return getRefreshFrequency()
        }
        
        set {
            setRefreshFrequency(newValue)
        }
    }
    
    class var changeAllSpaces: Bool {
        get {
            return getAllSpacesChanging()
        }
        
        set {
            setAllSpacesChanging(newValue)
        }
    }
    
    class var instanceUUID: String {
        return getInstanceUUID()
    }
    
    private class func getRootPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        if paths.count > 0 {
            return paths[0]
        }
        
        return ""
    }

    
    private class func getImagesPath() -> String {
        let rootPath = getRootPath()
        
        return rootPath
    }
    
    private class func getSettingsFilePath() -> String {
        let rootPath = getRootPath()
        
        return rootPath + "/snappr.subreddits.plist"
    }
    
    private class func getLastUpdatedImage() -> NSDate {
        let lastUpdated = NSUserDefaults.standardUserDefaults().objectForKey("last_updated")
        
        if let lastUpdatedDate = lastUpdated as? NSDate {
            return lastUpdatedDate
        }
        
        return NSDate.distantPast()
    }
    
    private class func setLastUpdatedImage(date: NSDate) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(date, forKey: "last_updated")
    }
    
    private class func getRefreshFrequency() -> NSTimeInterval {
        let defaults = NSUserDefaults.standardUserDefaults()
        let interval = defaults.doubleForKey("refreshFrequency")
        
        if interval <= 0 {
            return 18_000
        }
        
        return interval
    }
    
    private class func setRefreshFrequency(interval: NSTimeInterval) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(interval, forKey: "refreshFrequency")

        SRWallpaperChanger.sharedChanger().changeTimerWithNewRepetition(interval);
    }
    
    private class func getAllSpacesChanging() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey("changeAllSpaces")
    }
    
    private class func setAllSpacesChanging(changing: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(changing, forKey: "changeAllSpaces")
    }
    
    private class func getInstanceUUID() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let savedUUID = defaults.stringForKey("instanceUUID")
        
        if savedUUID != nil {
            return savedUUID!
        } else {
            let generatedUUID = NSUUID().UUIDString
            defaults.setObject(generatedUUID, forKey: "instanceUUID")
            return generatedUUID
        }
        
    }
}
