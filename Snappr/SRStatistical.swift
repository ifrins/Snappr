//
//  SRStatistical.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 7/11/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Foundation
import Amplitude


public class SRStatistical: NSObject  {
    public static let sharedStatitical = SRStatistical()
    
    public enum EventType: String {
        case OPEN_SETTINGS = "SETTINGS_OPEN"
        case WALLPAPER_CHANGE = "NEXT_WALLPAPER"
        case FORCED_WALLPAPER_CHANGE = "NEXT_WALLPAPER_FORCE"
        case OPEN_ABOUT = "ABOUT_OPEN"
        case OPEN_NOTIFICATION = "NOTIFICATION_OPEN"
        case OPEN_MENU = "MENU_OPEN"
    }
    
    private override init() {
        super.init()
Amplitude.instance().initializeApiKey("cd7b44895a1b31e4c35e101cf316285e")

        let userProperties: [NSObject : AnyObject]! = ["refreshFrequency" : SRSettings.refreshFrequency,
                                                       "subredditCount" : SRSubredditDataStore.sharedDatastore().subredditArray.count]
        
        Amplitude.instance().setUserProperties(userProperties)
    }
    
    public func trackEvent(eventType: EventType) {
        Amplitude.instance().logEvent(eventType.rawValue)
    }
    
    public func trackOpenAbout() {
        trackEvent(.OPEN_ABOUT)
    }
    
    public func trackOpenSettings() {
        trackEvent(.OPEN_SETTINGS)
    }
    
    public func trackOpenNotification() {
        trackEvent(.OPEN_NOTIFICATION)
    }
    
    public func trackWallpaperChange() {
        trackEvent(.WALLPAPER_CHANGE)
    }
    
    public func trackForcedWallpaperChange() {
        trackEvent(.FORCED_WALLPAPER_CHANGE)
    }
    
    public func trackOpenMenu() {
        trackEvent(.OPEN_MENU)
    }
}