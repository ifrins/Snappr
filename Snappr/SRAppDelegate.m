//
//  SRAppDelegate.m
//  Snappr
//
//  Copyright (c) 2014 Snappr. All rights reserved.
//

#import "SRAppDelegate.h"
#import "SRRedditParser.h"
#import "SRSubredditDataStore.h"
#import "SRWallpaperChanger.h"
#import "SRSetupWindowController.h"
#import "Snappr-Swift.h"
#import "SRUtils.h"

@implementation SRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [DevMateKit sendTrackingReport:nil delegate:nil];
    [DevMateKit setupIssuesController:nil reportingUnhandledIssues:YES];
#ifndef DEBUG
    [SRUtils setStartAtLogin:[self appURL] enabled:YES];
#endif
    [[SUUpdater sharedUpdater] setDelegate: [SRStatistical sharedStatitical]];
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:YES];
    [[SUUpdater sharedUpdater] setAutomaticallyDownloadsUpdates:YES];
    
    [[NSTimer timerWithTimeInterval:3600
                             target:self
                           selector:@selector(checkForUpdates)
                           userInfo:nil
                            repeats:YES] fire];
    
    [SRWallpaperChanger sharedChanger];
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

- (IBAction)showDonatePage:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://snappr.xyz/donate"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)showFeedbackPage:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://snappr.xyz/feedback"];
    [[NSWorkspace sharedWorkspace] openURL:url];
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
#if DEBUG
    NSLog(@"Snappr::Sparkle:: Checking for updates");
#endif
    [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
}

- (BOOL)updater:(DM_SUUpdater *)updater mayShowModalAlert:(NSAlert *)alert {
    return NO;
}

- (void)updater:(DM_SUUpdater *)updater willInstallUpdateOnQuit:(DM_SUAppcastItem *)item immediateInstallationInvocation:(NSInvocation *)invocation {
    [invocation invoke];
}

@end
