//
//  SRSubredditDataStore.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snappr-Swift.h"

@interface SRSubredditDataStore : NSObject <NSTableViewDataSource>

@property NSMutableArray *subredditArray;
@property RedditImage *currentImage;

+ (instancetype) sharedDatastore;

- (void)addSubreddit:(NSString *)subreddit;
- (void)removeSubreddit:(NSInteger)index;
- (void)save;

@end
