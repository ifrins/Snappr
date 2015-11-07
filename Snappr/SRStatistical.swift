//
//  SRStatistical.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 7/11/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Foundation
import Sparkle

public class SRStatistical: NSObject, SUUpdaterDelegate  {
    
    public static let sharedStatitical = SRStatistical()
    
    public func feedParametersForUpdater(updater: SUUpdater!, sendingSystemProfile sendingProfile: Bool) -> [AnyObject]! {
        var parameters = [Dictionary<String, String>]()
        
        #if DEBUG
            let debugDic = ["key": "debug",
                            "value": "true"]
            parameters.append(debugDic)
        #endif
        
        let uuidDic = ["key": "uuid",
                        "value": SRSettings.instanceUUID]
        
        let frequencyString = String(format: "%.0f", SRSettings.refreshFrequency)
        
        let refreshDic = ["key": "refresh",
                            "value": frequencyString]
        
        parameters.append(uuidDic)
        parameters.append(refreshDic)
        
        return parameters
    }
    
    public func trackWallpaperChange() {
        #if DEBUG
            return true;
        #endif

        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion")!
        
        let urlString = "https://origin.snappr.xyz/event/wallpaper_change?uuid=\(SRSettings.instanceUUID)&appVersion=\(appVersion)"
        let url = NSURL(string: urlString)
        
        let request = NSURLRequest(URL: url!)
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            var data: NSURLResponse?
            try! NSURLConnection.sendSynchronousRequest(request, returningResponse: &data)
        };
        
    }
}