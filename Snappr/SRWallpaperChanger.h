//
//  SRWallpaperChanger.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRWallpaperChanger : NSObject

@property NSTimer *timer;

+ (instancetype)sharedChanger;

- (void) nextWallpaper;
- (void) changeTimerWithNewRepetition:(NSTimeInterval)seconds;

@end