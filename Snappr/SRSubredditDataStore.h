//
//  SRSubredditDataStore.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRImage.h"

@interface SRSubredditDataStore : NSObject <NSTableViewDataSource>

@property NSMutableArray* subredditArray;
@property SRImage* currentImage;

+ (SRSubredditDataStore*) sharedDatastore;

- (void)addSubreddit:(NSString*) subreddit;
- (void)removeSubreddit:(NSInteger) index;
- (void)save;

@end
