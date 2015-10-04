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
        NSUserDefaults.standardUserDefaults().setObject(date, forKey: "last_updated")
    }
}
