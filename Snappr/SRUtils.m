//
//  SRUtils.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRUtils.h"

@implementation SRUtils

+ (BOOL) willStartAtLogin:(NSURL *)itemURL
{
    Boolean foundIt=false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));

        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                foundIt = CFEqual(URL, (__bridge CFTypeRef)(itemURL));
                CFRelease(URL);
                
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return (BOOL)foundIt;
}

+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled
{
    OSStatus status;
    LSSharedFileListItemRef existingItem = NULL;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge NSArray *)(LSSharedFileListCopySnapshot(loginItems, &seed));
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (__bridge LSSharedFileListItemRef)itemObject;
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, (__bridge CFTypeRef)(itemURL));
                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
        
        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
                                          NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
            
        } else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);
        
        CFRelease(loginItems);
    }       
}


@end
