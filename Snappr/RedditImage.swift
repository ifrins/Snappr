//
//  RedditImage.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 30/9/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Cocoa

@objc
class RedditImage: NSObject {
    private var internalImageURL: NSURL?
    
    var title:      String?
    var resolution: NSSize?
    var redditURL:  NSURL?
    var imageURL:   NSURL? {
        get {
            return self.internalImageURL
        }
        set {
            if let url = newValue {
                self.internalImageURL = parseImageLink(url)
            }
        }
    }
    
    init(JSONData: NSDictionary) {
        super.init()
        
        let data = JSONData.objectForKey("data")
        
        if let url = data?.objectForKey("url") {
            self.imageURL = NSURL.init(string: url as! String)!
        }
        
        if let data_title = data?.objectForKey("title") {
            self.title = data_title as! String
        }
        
        if let permalink = data?.objectForKey("permalink") {
            let redditURLString = "http://reddit.com\(permalink)"
            self.redditURL = NSURL.init(string: redditURLString)
        }
    }
    
    func getImage() -> NSImage? {
        if self.imageURL == nil {
            return nil
        }
        
        let image = NSImage.init(contentsOfURL: self.imageURL!)
        return image
    }
    
    private func parseImageLink(url: NSURL) -> NSURL? {
        let host = url.host
        
        if host == "imgur.com" {
            let relativePath = url.relativePath
            return NSURL(string: "http://i.imgur.com\(relativePath).jpg")
        } else {
            return url
        }
    }
}