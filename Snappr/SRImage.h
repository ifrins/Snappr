//
//  SRImage.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRImage : NSObject

@property  NSString* title;
@property  NSString* redditUrl;
@property  NSString* imageLink;
@property  NSRect resolution;


- (SRImage*) initWithJSONData:(NSDictionary*) data;

@end
