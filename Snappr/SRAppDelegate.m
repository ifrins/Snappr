//
//  SRAppDelegate.m
//  Snappr
//
//  Copyright (c) 2014 Snappr. All rights reserved.
//

#import "SRAppDelegate.h"
#import "SRRedditParser.h"
#import "SRSubredditDataStore.h"
#import "SRSetupWindowController.h"
#import "Snappr-Swift.h"
#import "SRUtils.h"


@implementation SRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [DevMateKit sendTrackingReport:nil delegate:nil];
    
#ifndef DEBUG
    [DevMateKit setupIssuesController:nil reportingUnhandledIssues:YES];
    [SRUtils setStartAtLogin:[self appURL] enabled:YES];
#endif
    [[SUUpdater sharedUpdater] setDelegate:self];
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:YES];
    [[SUUpdater sharedUpdater] setAutomaticallyDownloadsUpdates:YES];
    
    [[NSTimer timerWithTimeInterval:3600
                             target:self
                           selector:@selector(checkForUpdates)
                           userInfo:nil
                            repeats:YES] fire];
    
    [WallpaperChangerService sharedChanger];
}

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setTarget:self];
    [_statusItem setAction:@selector(openMenu)];
    [_statusItem setHighlightMode:YES];
    NSImage *menubarIcon = [NSImage imageNamed:@"MenuBar"];
    [menubarIcon setTemplate:YES];
    [_statusItem setImage:menubarIcon];
}

- (void)openMenu {
    [[SRStatistical sharedStatitical] trackOpenMenu];
    [_statusItem popUpStatusItemMenu:_statusMenu];
}

- (IBAction)nextWallpaper:(id)sender {
    [[SRStatistical sharedStatitical] trackForcedWallpaperChange];
    [[WallpaperChangerService sharedChanger] nextWallpaper];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate: self];
}

- (IBAction)openAbout:(id)sender {
    [[SRStatistical sharedStatitical] trackOpenAbout];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction)showDonatePage:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://snappr.xyz/donate"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)showFeedbackPage:(id)sender {
    [DevMateKit showFeedbackDialog:nil inMode:DMFeedbackIndependentMode];
}

- (IBAction)viewCurrentWallpaper:(id)sender {
    RedditImage *image = [[SRSubredditDataStore sharedDatastore] currentImage];
    
    [[NSWorkspace sharedWorkspace] openURL:image.redditURL];
}

- (IBAction)openSettings:(id)sender {
    [[SRStatistical sharedStatitical] trackOpenSettings];
    
    if (_settingsWindowController == nil) {
        _settingsWindowController = [[SRSetupWindowController alloc] initWithWindowNibName:@"SRSetupWindowController"];
    }
    
    [_settingsWindowController showWindow:_settingsWindowController.window];
    [[_settingsWindowController window] makeKeyAndOrderFront:_settingsWindowController.window];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
    [[SRStatistical sharedStatitical] trackOpenNotification];
    
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
