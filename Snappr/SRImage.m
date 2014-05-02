//
//  SRImage.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRImage.h"

@implementation SRImage

@synthesize imageLink;

- (SRImage*) initWithJSONData:(NSDictionary*) content
{
    self = [super init];
    
    NSDictionary* data = (NSDictionary*) [content objectForKey:@"data"];
    
    [self setImageLink: [data objectForKey:@"url"]];
    [self setRedditUrl:[NSString stringWithFormat:@"http://reddit.com%@", [data objectForKey:@"permalink"]]];
    [self setTitle:[data objectForKey:@"title"]];
    
    return self;

}

- (NSString*) imageLink
{
    return imageLink;
}

- (void) setImageLink:(NSString *) image
{
    NSURL* url = [NSURL URLWithString:image];
    
    
    if ([[url host] isEqual:@"imgur.com"]) {
        imageLink =[NSString stringWithFormat:@"http://i.imgur.com%@.jpg", [url relativePath]];
    
    } else if ([[url host] isEqual:@"reddit.com"]) {
        imageLink = @"";
    
    } else {
        imageLink = image;
    }
}

@end
