//
//  SRWallpaperChanger.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRWallpaperChanger.h"
#import "Snappr-Swift.h"
#import "SRRedditParser.h"
#import "NSMutableArray_Shuffling.h"
#import "NSFileManager+DirectoryLocations.h"
#import "NSString+MD5.h"
#import "SRSubredditDataStore.h"

#import "NSTimer+NoodleExtensions.h"

@interface SRWallpaperChanger ()

@property NSTimer   *timer;
@property NSDate    *plannedFireDate;

@end

@implementation SRWallpaperChanger

+ (instancetype)sharedChanger {
    static dispatch_once_t pred;
    static SRWallpaperChanger *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SRWallpaperChanger alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    NSNotificationCenter *notifcenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    
    [notifcenter addObserver:self
                    selector:@selector(willSleep)
                        name:NSWorkspaceWillSleepNotification
                      object:nil];
    
    [notifcenter addObserver:self
                    selector:@selector(willWake)
                        name:NSWorkspaceDidWakeNotification
                      object:nil];
    
    [notifcenter addObserver:self
                    selector:@selector(checkIfSpaceNeedsWallpaper)
                        name:NSWorkspaceActiveSpaceDidChangeNotification
                      object:nil];
    
    [self scheduleInitialChange];
    
    return self;    
}

- (void)scheduleInitialChange {
    NSDate *lastUpdate = [SRSettings lastUpdated];
    NSTimeInterval lastUpdateDelta = fabs(lastUpdate.timeIntervalSinceNow);
    NSTimeInterval updateInterval = [SRSettings refreshFrequency];
    
    if (lastUpdateDelta > updateInterval) {
        [self nextWallpaper];
    } else {
        NSTimeInterval newInterval = updateInterval - lastUpdateDelta;
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:newInterval
                                                      target:self
                                                    selector:@selector(nextWallpaperFromTimer)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)willSleep {
    NSLog(@"Will sleep");
    if ([self.timer isValid]) {
        self.plannedFireDate = self.timer.fireDate;
        [self.timer invalidate];
    }
}

- (void)willWake {
    NSLog(@"Will sleep");
    NSTimeInterval timeInterval = [self.plannedFireDate timeIntervalSinceNow];
    
    if (timeInterval <= 0) {
        [self nextWallpaperFromTimer];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                      target:self
                                                    selector:@selector(nextWallpaperFromTimer)
                                                    userInfo:nil
                                                     repeats:NO];
    }
    
    self.plannedFireDate = nil;
}

- (void)checkIfSpaceNeedsWallpaper {
    if ([SRSettings changeAllSpaces]) {
        NSArray<NSScreen *> *screens = [NSScreen screens];
        RedditImage *image = [[SRSubredditDataStore sharedDatastore] currentImage];
    
        NSString *basePath = [SRSettings imagesPath];
        NSString *imageURLMD5 = [image.imageURL.description MD5String];
        NSString *path = [basePath stringByAppendingPathComponent:imageURLMD5];

        NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:path];
    
        for (NSScreen *screen in screens) {
            NSURL *screenImageURL;
            screenImageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:screen];
        
            if (![screenImageURL isEqualTo:fileUrl]) {
                NSError *error;
                [[NSWorkspace sharedWorkspace] setDesktopImageURL:fileUrl
                                                        forScreen:screen
                                                          options:nil
                                                            error:&error];
            }
        }
    }
}

- (void)nextWallpaperFromTimer {
    NSDate *lastUpdateDate;
    lastUpdateDate = [SRSubredditDataStore sharedDatastore].lastImageDownloadDate;
    
    NSLog(@"New Wallpaper from timer!");
    
    [self nextWallpaper];
}

- (void)nextWallpaper {
    NSLog(@"Next wallpaper...");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSInteger attempts = 0;
        
        [self cleanOldFiles];
        
        while (attempts < 5) {
            NSArray<RedditImage *> *images = [self getAllImages];
            NSSize minSize = [self getMinimumSize];
        
            NSImage *imageDataToUse;
            RedditImage *imageToUse;
        
            NSString *path = [SRSettings imagesPath];
        
            for (RedditImage *refImage in images) {
                // Image has already been used as a wallpaper
                if ([self hasImageBeenShown:refImage]) continue;

                NSImage *proveImage = [refImage getImage];

                // We couldn't download the image
                if (proveImage == nil) continue;
            
            
                NSSize imageSize = [proveImage size];
            
                if ([self imageWithSize:imageSize willSupportScreenWithSize:minSize]) {
                    imageDataToUse = proveImage;
                    imageToUse = refImage;
                    break;
                }
            }
        
            if (imageToUse == nil) {
                attempts++;
                NSLog(@"Failed download… Retrying… %ld", attempts);
                
                sleep(pow(3, attempts) + 5);
                continue;
            }
        
            NSBitmapImageRep *imgRep = [[imageDataToUse representations] objectAtIndex: 0];
            NSData *imageData = [imgRep representationUsingType:NSJPEGFileType properties:nil];
        
            NSString *imageLinkMD5 = [imageToUse.imageURL.description MD5String];
        
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[path stringByAppendingPathComponent: imageLinkMD5]];

            [imageData writeToURL:fileURL atomically:YES];
        
            NSArray *screens = [NSScreen screens];
        
            NSLog(@"SR – Setting wallpaper to %@", fileURL);
        
            for (NSScreen *screen in screens) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError* error;
                    [[NSWorkspace sharedWorkspace] setDesktopImageURL:fileURL forScreen:screen options:nil error:&error];
                    
                    if (error == nil) {
                        [[SRSubredditDataStore sharedDatastore] setCurrentImage:imageToUse];
                        [SRSettings setLastUpdated:[NSDate date]];
                        [self sendNotificationForImage:imageToUse];
                    }
                });
            }
            break;
        }
        
        [self scheduleNewChange];
    });
}

- (void)changeTimerWithNewRepetition:(NSTimeInterval)seconds {
    NSLog(@"Set new interval of %f seconds", seconds);
    
    if ([self.timer isValid]) {
        NSTimeInterval remaining = self.timer.fireDate.timeIntervalSinceNow;
        NSTimeInterval newInterval = seconds - remaining;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:newInterval
                                                      target:self
                                                    selector:@selector(nextWallpaperFromTimer)
                                                    userInfo:nil
                                                     repeats:NO];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                      target:self
                                                    selector:@selector(nextWallpaperFromTimer)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (NSArray *)getAllImages {
    NSMutableArray<RedditImage *> *allImages = [[NSMutableArray alloc] init];
    NSArray *subreddits = [[[SRSubredditDataStore sharedDatastore] subredditArray] copy];
    
    for (NSString *subreddit in subreddits) {
        NSArray<RedditImage *> *subredditImages;
        subredditImages = [[SRRedditParser sharedParser] getImagesFor:subreddit];
        [allImages addObjectsFromArray:subredditImages];
    }
    
    [allImages shuffle];
    
    return [allImages copy];
}

- (BOOL)hasImageBeenShown:(RedditImage *)image {
    NSString *basePath = [SRSettings imagesPath];
    NSString *imageURLMD5 = [image.imageURL.description MD5String];
    NSString *path = [basePath stringByAppendingPathComponent:imageURLMD5];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    return NO;
}

- (NSSize)getMinimumSize {
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    
    NSArray *screens = [NSScreen screens];
    
    for (NSScreen *screen in screens) {
        NSRect screenRect = [screen convertRectFromBacking:[screen frame]];
        NSSize screenSize = screenRect.size;
        
        if (screenSize.height > maxHeight) {
            maxHeight = screenSize.height;
        }
        
        if (screenSize.width > maxWidth) {
            maxWidth = screenSize.width;
        }
    }
    
    return NSMakeSize(maxWidth, maxHeight);
}

- (BOOL) imageWithSize:(NSSize)imageSize willSupportScreenWithSize:(NSSize)screenSize {
    if (imageSize.width >= screenSize.width && imageSize.height >= screenSize.height) {
        return YES;
    }

    return NO;
}

- (void)sendNotificationForImage:(RedditImage *)image {
    NSString *imageLinkString = image.imageURL.description;
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = image.title;
    notification.informativeText = NSLocalizedString(@"New Wallpaper", "New wallpaper notification title") ;
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = [NSDictionary dictionaryWithObject:imageLinkString
                                                        forKey:@"link"];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)scheduleNewChange {
    dispatch_sync(dispatch_get_main_queue(), ^() {
        NSTimeInterval timeInterval = [SRSettings refreshFrequency];
        
        [self.timer invalidate];
        self.timer = nil;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                      target:self
                                                    selector:@selector(nextWallpaperFromTimer)
                                                    userInfo:nil
                                                     repeats:NO];
        self.timer.tolerance = 60;
    });
}

- (void)cleanOldFiles {
    NSString *dirPath = [SRSettings imagesPath];
    NSURL *pathURL = [[NSURL alloc] initFileURLWithPath:dirPath isDirectory:YES];
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pathURL includingPropertiesForKeys:@[NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];

    NSTimeInterval deletionTarget = (5 * 24 * 3600); // Interval of seconds for 5 days
    
    for (NSURL *file in dirFiles)
    {
        NSDate *modificationDate = nil;
        [file getResourceValue:&modificationDate forKey:NSURLContentModificationDateKey error:nil];
        
        if (![[file pathExtension] isEqual:@"plist"] && modificationDate != nil && [[NSDate date] timeIntervalSinceDate:modificationDate] >= deletionTarget)
        {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        
    }
}

@end
