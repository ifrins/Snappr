//
//  SRAppDelegate.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRAppDelegate.h"
#import "SRRedditParser.h"
#import "SRSubredditDataStore.h"
#import "SRWallpaperChanger.h"
#import "SRSetupWindowController.h"
#import "Snappr-Swift.h"
#import "SRUtils.h"
#import <Sparkle/Sparkle.h>

@implementation SRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [SRUtils setStartAtLogin:[self appURL] enabled:YES];
    [[SUUpdater sharedUpdater] setSendsSystemProfile:YES];
    [[NSTimer timerWithTimeInterval:3600
                             target:self
                           selector:@selector(checkForUpdates)
                           userInfo:nil
                            repeats:YES] fire];
}

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_statusMenu];
    [_statusItem setHighlightMode:YES];
    NSImage *menubarIcon = [NSImage imageNamed:@"MenuBar"];
    [menubarIcon setTemplate:YES];
    [_statusItem setImage:menubarIcon];
}

- (IBAction)nextWallpaper:(id)sender {
    [[SRWallpaperChanger sharedChanger] nextWallpaper];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate: self];
}

- (IBAction)openAbout:(id)sender {
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction)viewCurrentWallpaper:(id)sender {
    RedditImage *image = [[SRSubredditDataStore sharedDatastore] currentImage];
    
    [[NSWorkspace sharedWorkspace] openURL:image.redditURL];
}

- (IBAction)openSettings:(id)sender {
    if (_settingsWindowController == nil) {
        _settingsWindowController = [[SRSetupWindowController alloc] initWithWindowNibName:@"SRSetupWindowController"];
    }
    
    [_settingsWindowController showWindow:_settingsWindowController.window];
    [[_settingsWindowController window] makeKeyAndOrderFront:_settingsWindowController.window];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
    NSDictionary* userData = [notification userInfo];
    
    if ([[userData allKeys] containsObject:@"link"]) {
        NSString* redditLink = [userData objectForKey:@"link"];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:redditLink]];
    }
}

- (NSURL *)appURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void)checkForUpdates {
    NSLog(@"Checking for updates!");
    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}


@end
