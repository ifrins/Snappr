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
    [self nextWallpaper];
    return self;    
}

- (void)nextWallpaper {
    NSLog(@"Next wallpaper...");
    [self scheduleNewChange];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self cleanOldFiles];
        
        NSArray* images = [self getAllImages];
        NSSize minSize = [self getMinimumSize];
        NSImage* imageToUse = nil;
        int imageToUseIndex = -1;
        NSString* path = [self imagesFolderPath];
        
        for (RedditImage *image in images) {
            NSLog(@"%@", image.title);
        }
        
        for (int i = 0; i < [images count]; i++) {
            RedditImage *refImage = [images objectAtIndex:i];
        
            NSImage *proveImage = [refImage getImage];
            
            if (proveImage == nil) continue;
        
        
            if ([self hasImageBeenShown:refImage]) {
                continue;
            }
        
            NSSize imageSize = [proveImage size];
            
            if (imageSize.height == 0) {
                NSLog(@"URL not pointing to the file: %@", refImage.imageURL);
            }

            if ([self imageWithSize:imageSize willSupportScreenWithSize:minSize]) {
                imageToUse = proveImage;
                imageToUseIndex = i;
                break;
            }
        }
    
        if (imageToUseIndex == -1)
        {
            return;
        }
    
        RedditImage *imageToUseRef = [images objectAtIndex:imageToUseIndex];
        
        NSBitmapImageRep *imgRep = [[imageToUse representations] objectAtIndex: 0];
        NSData* imageData = [imgRep representationUsingType:NSJPEGFileType properties:nil];
        
        NSString *imageLinkMD5 = [[NSString stringWithFormat:@"%@", imageToUseRef.imageURL] MD5String];
        
        NSURL* fileURL = [[NSURL alloc] initFileURLWithPath:[path stringByAppendingPathComponent: imageLinkMD5]];

        [imageData writeToURL:fileURL atomically:YES];
        
        NSArray* screens = [NSScreen screens];
    
        for (int i = 0; i < [screens count]; i++) {
            NSScreen* screen = [screens objectAtIndex:i];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error;
                //[[NSWorkspace sharedWorkspace] setDesktopImageURL:fileURL forScreen:screen options:nil error:&error];
                
                if (error == nil)
                {
                    [[SRSubredditDataStore sharedDatastore] setCurrentImage:imageToUseRef];
                    [self sendNotificationWithTitle:[imageToUseRef title] andLink:imageToUseRef.redditURL];
                }
            });
        }
    });
    
    
}

- (void)changeTimerWithNewRepetition:(NSTimeInterval)seconds {
    NSLog(@"Set new interval of %f seconds", seconds);
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(nextWallpaper) userInfo:nil repeats:YES];
    
    [_timer fire];
}

- (NSArray*)getAllImages {
    NSMutableArray* allImages = [[NSMutableArray alloc] init];
    NSArray* subreddits = [[SRSubredditDataStore sharedDatastore] subredditArray];
    
    for (int i = 0; i < [subreddits count]; i++) {
        [allImages addObjectsFromArray:[[SRRedditParser sharedParser] getImagesFor:[subreddits objectAtIndex:i]]];
    }
    
    [allImages shuffle];
    
    return allImages;
}

- (BOOL)hasImageBeenShown:(RedditImage *)image {
    NSString *basePath = [self imagesFolderPath];
    NSString *imageURLMD5 = [[NSString stringWithFormat:@"%@", image.imageURL] MD5String];
    NSString *path = [basePath stringByAppendingPathComponent:imageURLMD5];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    return NO;
    
}

- (NSSize)getMinimumSize {
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    
    NSArray* screens = [NSScreen screens];
    
    for (int i = 0; i < [screens count]; i++) {
        NSScreen* screen = [screens objectAtIndex:i];
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

- (void)sendNotificationWithTitle:(NSString *)title andLink:(NSURL *)linkUrl {
    NSString *imageLinkString = [NSString stringWithFormat:@"%@", linkUrl];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = NSLocalizedString(@"New Wallpaper", "New wallpaper notification title") ;
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.userInfo = [NSDictionary dictionaryWithObject:imageLinkString
                                                        forKey:@"link"];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (NSTimeInterval)getChangeInterval {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSTimeInterval interval = [prefs integerForKey:@"refreshFrequency"];
    
    if (interval <= 0) {
        interval = 18000;
    }
    
    return interval;
}

- (void)scheduleNewChange {
    [NSTimer scheduledTimerWithAbsoluteFireDate:[NSDate dateWithTimeIntervalSinceNow:[self getChangeInterval]] target:self selector:@selector(nextWallpaper) userInfo:nil];
}

- (void)cleanOldFiles {
    NSString *dirPath = [self imagesFolderPath];
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

- (NSString *)imagesFolderPath {
    static NSString *folderPath;
#warning Create specific folder for images
    if (folderPath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        folderPath = documentsPath;
    }
    
    NSLog(@"Images folder path: %@", folderPath);
    
    return folderPath;
}


@end
