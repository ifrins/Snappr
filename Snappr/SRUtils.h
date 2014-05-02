//
//  SRUtils.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRUtils : NSObject

+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;
+ (BOOL) willStartAtLogin:(NSURL *)itemURL;

@end
