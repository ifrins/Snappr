//
//  WallpaperChangerService.swift
//  Snappr
//
//  Created by Francesc Bruguera on 8/7/16.
//  Copyright © 2016 Snappr. All rights reserved.
//

import Foundation

@objc public class WallpaperChangerService : NSObject {
    private var timer: NSTimer?
    private var plannedFireDate: NSDate?
    
    static let sharedChanger = WallpaperChangerService()
    
    override private init() {
        super.init()
        let notificationCenter = NSWorkspace.sharedWorkspace().notificationCenter
        notificationCenter.addObserver(self,
                                       selector: #selector(willSleep),
                                       name: NSWorkspaceWillSleepNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(willWake),
                                       name: NSWorkspaceDidWakeNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(checkIfSpaceNeedsWallpaper),
                                       name: NSWorkspaceActiveSpaceDidChangeNotification,
                                       object: nil)
        
        scheduleInitialChange()
    }
    
    func nextWallpaper() {
        print("Next wallpaper…")
        SRStatistical.sharedStatitical.trackEvent(.WALLPAPER_CHANGE)
        let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        dispatch_async(globalQueue, {
            var attempts = 0
            self.cleanOldFiles()
            
            while attempts < 5 {
                let changedImage = self.changeImage()
                
                if !changedImage {
                    attempts += 1
                } else {
                    break
                }
            }
        })
    }
    
    func changeTimerWithNewRepetition(seconds: NSTimeInterval) {
        if timer != nil && timer!.valid {
            let remaining = timer!.fireDate.timeIntervalSinceNow
            let newInterval = seconds - remaining
            
            timer = NSTimer.scheduledTimerWithTimeInterval(newInterval,
                                                           target: self,
                                                           selector: #selector(nextWallpaperFromTimer),
                                                           userInfo: nil,
                                                           repeats: false)
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(seconds,
                                                           target: self,
                                                           selector: #selector(nextWallpaperFromTimer),
                                                           userInfo: nil,
                                                           repeats: false)
        }
    }
    
    private func cleanOldFiles() {
        let dirPath = SRSettings.imagesPath
        let pathURL = NSURL(fileURLWithPath: dirPath, isDirectory: true)
        
        let fileManager = NSFileManager.defaultManager()
        
        let dirFiles = try! fileManager.contentsOfDirectoryAtURL(pathURL, includingPropertiesForKeys: [NSURLContentModificationDateKey], options: .SkipsHiddenFiles)
        
        let deletionTarget = NSTimeInterval(5 * 24 * 3600)
        
        for file in dirFiles {
            var modificationDateRaw: AnyObject?
            try! file.getResourceValue(&modificationDateRaw, forKey: NSURLContentModificationDateKey)
            
            if file.pathExtension! == "plist" {
                continue
            }
            
            let modificationDate = modificationDateRaw as! NSDate!
            
            let timeInterval = NSDate().timeIntervalSinceDate(modificationDate)
            
            if timeInterval >= deletionTarget {
                try? NSFileManager.defaultManager().removeItemAtURL(file)
            }
        }
    }
    
    private func changeImage() -> Bool {
        let images: [RedditImage] = getAllImages()
        let minimumSize = getMinimumSize()
        
        var imageDataToUse: NSImage? = nil
        var imageToUse: RedditImage? = nil
        
        for refImage in images {
            let imageShown = hasImageBeenShown(refImage)
            var imageSizeSupported = true
            
            let inferredResolution = refImage.resolution
            
            if inferredResolution != nil {
                imageSizeSupported = sizeWillSupportScreenSize(inferredResolution!, screenResolution: minimumSize)
            }
            
            if imageShown || !imageSizeSupported {
                continue
            }
            
            let proveImage = refImage.getImage()
            
            if proveImage == nil {
                continue
            }
            
            let realSize = proveImage!.size
            let appropiateSize = sizeWillSupportScreenSize(realSize, screenResolution: minimumSize)
            
            if appropiateSize {
                imageToUse = refImage
                imageDataToUse = proveImage!
                break
            }
        }
        
        if imageDataToUse != nil && imageToUse != nil {
            setImageAsWallpaper(imageToUse!, imageData: imageDataToUse!)
            return true
        }
        
        return false
    }
    
    private func setImageAsWallpaper(refImage: RedditImage, imageData: NSImage) {
        let queue = dispatch_get_main_queue()
        let imagesPath = SRSettings.imagesPath
        
        let imgRep = imageData.representations[0] as! NSBitmapImageRep
        let imageData = imgRep.representationUsingType(.NSPNGFileType,
                                                       properties: [:])
        
        let imageHash = refImage.getHash()
        
        let filePath = imagesPath.stringByAppendingString("/\(imageHash).png")
        let fileURL = NSURL(fileURLWithPath: filePath)
        
        imageData?.writeToURL(fileURL, atomically: true)
        
        dispatch_async(queue, {
            let screens = NSScreen.screens()
            
            for screen in screens! {
                try? NSWorkspace.sharedWorkspace().setDesktopImageURL(fileURL,
                    forScreen: screen,
                    options: [:])
                
                SRSubredditDataStore.sharedDatastore().currentImage = refImage
                SRSettings.lastUpdated = NSDate()
            }
            
            self.sendNotificationForImage(refImage)
            self.scheduleNewChange()
        })
    }
    
    private func sendNotificationForImage(image: RedditImage) {
        let imageUrl = image.redditURL
        if imageUrl != nil {
            let imageLink = imageUrl!.description
            
            let notification = NSUserNotification()
            notification.title = image.title
            notification.informativeText = NSLocalizedString("New Wallpaper", comment: "New wallpaper notification test")
            notification.userInfo = ["link" : imageLink]
            
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        }
    }
    
    private func sizeWillSupportScreenSize(realSize: NSSize, screenResolution: NSSize) -> Bool {
        return realSize.width >= screenResolution.width && realSize.height >= screenResolution.height
    }
    
    private func scheduleNewChange() {
        let timeInterval = SRSettings.refreshFrequency
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
                                                       target: self,
                                                       selector: #selector(nextWallpaperFromTimer),
                                                       userInfo: nil,
                                                       repeats: false)
        timer!.tolerance = 60
    }
    
    private func scheduleInitialChange() {
        let lastUpdate = SRSettings.lastUpdated
        let lastUpdateDelta = lastUpdate.timeIntervalSinceNow
        let updateInterval = SRSettings.refreshFrequency
        
        if lastUpdateDelta > updateInterval {
            nextWallpaper()
        } else {
            let newTimeInterval = updateInterval - lastUpdateDelta
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(newTimeInterval,
                                                           target: self,
                                                           selector: #selector(nextWallpaperFromTimer),
                                                           userInfo: nil,
                                                           repeats: false)
        }
    }
    
    private func hasImageBeenShown(image: RedditImage) -> Bool {
        let basePath = SRSettings.imagesPath
        let imageHash = image.getHash()
        let path = basePath.stringByAppendingString("/\(imageHash).png")
        
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    private func getAllImages() -> [RedditImage] {
        var allImages: [RedditImage] = []
        let subreddits = SRSubredditDataStore.sharedDatastore().subredditArray as! [String]
        
        for subreddit in subreddits {
            let subredditImages = SRRedditParser.sharedParser().getImagesFor(subreddit) as! [RedditImage]
            allImages.appendContentsOf(subredditImages)
        }
        
        allImages.shuffle()
        
        let immutableList = allImages
        return immutableList
    }
    
    private func getMinimumSize() -> NSSize {
        var maxWidth = CGFloat(0)
        var maxHeight = CGFloat(0)
        
        let screens = NSScreen.screens()!
        
        for screen in screens {
            let screenRect = screen.convertRectFromBacking(screen.frame)
            let screenSize = screenRect.size
            
            if screenSize.height > maxHeight {
                maxHeight = screenSize.height
            }
            
            if screenSize.width > maxWidth {
                maxWidth = screenSize.width
            }
        }
        
        return NSSize(width: maxWidth, height: maxHeight)
    }
    
    @objc public func willSleep(notification: NSNotification) {
        if timer != nil && timer!.valid {
            plannedFireDate = timer?.fireDate
            timer?.invalidate()
        }
    }
    
    @objc public func willWake(notification: NSNotification) {
        let timeInterval = plannedFireDate?.timeIntervalSinceNow
        
        if timeInterval == nil {
            return
        }
        
        if timeInterval <= 0 {
            nextWallpaperFromTimer()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval!,
                                                           target: self,
                                                           selector: #selector(nextWallpaperFromTimer),
                                                           userInfo: nil,
                                                           repeats: false);
        }
    }
    
    @objc func checkIfSpaceNeedsWallpaper() {
        let currentImage = SRSubredditDataStore.sharedDatastore().currentImage
        if currentImage != nil && SRSettings.changeAllSpaces {
            let screens = NSScreen.screens()!
            let path = currentImage.getFilePath()
            let fileURL = NSURL(fileURLWithPath: path)
            let workspace = NSWorkspace.sharedWorkspace()
            
            for screen in screens {
                let screenImageURL = workspace.desktopImageURLForScreen(screen)!
                
                if screenImageURL != fileURL {
                    try? workspace.setDesktopImageURL(fileURL,
                                                      forScreen: screen,
                                                      options: [:])
                }
            }
        }
    }
    
    @objc private func nextWallpaperFromTimer() {
        nextWallpaper()
    }
}
