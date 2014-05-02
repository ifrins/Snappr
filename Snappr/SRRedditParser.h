//
//  SRRedditParser.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRRedditParser : NSObject

+ (SRRedditParser *) sharedParser;

- (NSArray*) getImagesFor:(NSString*) subreddit;

@end
