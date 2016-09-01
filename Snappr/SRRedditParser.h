//
//  SRRedditParser.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RedditImage;

@interface SRRedditParser : NSObject

+ (nonnull SRRedditParser *)sharedParser;

- (nonnull NSArray<RedditImage *> *)getImagesFor:(nonnull NSString *)subreddit;

@end
