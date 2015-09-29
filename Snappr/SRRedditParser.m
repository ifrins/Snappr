//
//  SRRedditParser.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRRedditParser.h"
#import "SRImage.h"

@implementation SRRedditParser

+ (SRRedditParser *) sharedParser {
    static dispatch_once_t pred;
    static SRRedditParser *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SRRedditParser alloc] init];
    });
    
    return shared;
}

- (NSArray *)getImagesFor:(NSString *)subreddit {
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://reddit.com/r/%@/hot.json", subreddit]];
    NSMutableURLRequest *subredditRequest = [NSMutableURLRequest requestWithURL:url
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                timeoutInterval:15.0];
    
    [subredditRequest addValue:@"Snappr/1.1" forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *subredditData = [NSURLConnection sendSynchronousRequest:subredditRequest
                                                  returningResponse:&response
                                                              error:&error];
    
    
    if (error != nil || subredditData == nil) {
        NSLog(@"***ERROR! Fetching data: %@ ***", error);
        return nil;
    }
    
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:subredditData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&error];
    
    subredditData = nil;
    
    if (error != nil) {
        NSLog(@"**ERROR! Parsing data: %@ ***", error);
    }
    
    NSArray *childrenPosts = (NSArray*) [(NSDictionary*)[result objectForKey:@"data"] objectForKey:@"children"];
    
    for (int i = 0; i < [childrenPosts count]; i++) {
        SRImage *image = [[SRImage alloc] initWithJSONData:[childrenPosts objectAtIndex:i]];
        [imagesArray addObject:image];
    }
    
    result = nil;
    
    return imagesArray;

}

@end
