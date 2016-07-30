//
//  SRSubredditDataStore.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRSubredditDataStore.h"

#import "Snappr-Swift.h"

@implementation SRSubredditDataStore

+ (instancetype)sharedDatastore {
    static dispatch_once_t pred;
    static SRSubredditDataStore *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SRSubredditDataStore alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    
    NSString *subredditsPath = [SRSettings settingsPath];

    NSArray *array = [NSArray arrayWithContentsOfFile: subredditsPath];
    _subredditArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    
    if ([_subredditArray count] == 0) {
        [_subredditArray addObject:@"earthporn"];
        [_subredditArray addObject:@"skyporn"];
        [_subredditArray addObject:@"cityporn"];
    }
    
    _lastImageDownloadDate = [NSDate distantPast];
    
    return self;
}

- (void)addSubreddit:(NSString*) subreddit {
    [_subredditArray addObject:subreddit];
    [self save];
}

- (void)removeSubreddit:(NSInteger) index; {
    if ([_subredditArray count] > index) {
        [_subredditArray removeObjectAtIndex:index];
        [self save];
    }
}

- (void)save {
    NSString *subredditsPath = [SRSettings settingsPath];
    [_subredditArray writeToFile:subredditsPath atomically:YES];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_subredditArray count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex {
    return [_subredditArray objectAtIndex:rowIndex];
}

@end
