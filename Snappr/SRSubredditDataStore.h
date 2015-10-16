//
//  SRSubredditDataStore.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

@import Cocoa;

@class RedditImage;

@interface SRSubredditDataStore : NSObject <NSTableViewDataSource>

@property NSMutableArray<NSString *> *subredditArray;
@property RedditImage *currentImage;
@property NSDate *lastImageDownloadDate;

+ (instancetype) sharedDatastore;

- (void)addSubreddit:(NSString *)subreddit;
- (void)removeSubreddit:(NSInteger)index;
- (void)save;

@end
