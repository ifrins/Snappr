//
//  RedditImage.swift
//  Snappr
//
//  Created by Francesc Bruguera Moriscot on 30/9/15.
//  Copyright © 2015 Snapr. All rights reserved.
//

import Cocoa

@objc public class RedditImage: NSObject {
    private struct ImageMetadataDetails {
        var resolution: NSSize
        var imageUrl: NSURL
    }
    
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
        
        let data = JSONData.objectForKey("data") as! NSDictionary!
        
        let imageMetadata = getPreviewMetadata(data)
        
        if imageMetadata == nil {
            if let url = data?.objectForKey("url") {
                self.imageURL = NSURL.init(string: url as! String)
            }
        } else {
            self.imageURL = imageMetadata?.imageUrl
            self.resolution = (imageMetadata?.resolution)!
        }
        
        if let data_title = data?.objectForKey("title") {
            self.title = data_title as? String
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
    
    func getHash() -> String {
        if imageURL != nil {
            let linkString = imageURL!.description as! NSString
            return linkString.MD5String()
        }
        
        return ""
    }
    
    func getFilePath() -> String {
        let basePath = SRSettings.imagesPath
        let imageHash = getHash()
        
        let path = basePath.stringByAppendingString("/\(imageHash).png")
        return path
    }
    
    private func parseImageLink(url: NSURL) -> NSURL? {
        let host = url.host
        
        if host == "imgur.com" {
            let relativePath = url.relativePath
            return NSURL(string: "https://i.imgur.com\(relativePath).jpg")
        } else {
            return url
        }
    }
    
    private func getPreviewMetadata(data: NSDictionary) -> ImageMetadataDetails? {
        let preview = data.objectForKey("preview")
        
        if preview == nil {
            return nil
        }
        
        let images = preview!.objectForKey("images") as! [Dictionary<String, AnyObject>]
        
        for item in images {
            if item.keys.contains("source") {
                let source = item["source"]
                let size = NSSize(width: source!["width"] as! CGFloat, height: source!["height"] as! CGFloat)
                let imageUrl = NSURL(string: source!["url"] as! String)!
                return ImageMetadataDetails(resolution: size, imageUrl: imageUrl)
            }
        }
        
        return nil
    }
}