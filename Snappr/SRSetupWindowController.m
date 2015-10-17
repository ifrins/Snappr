//
//  SRSetupWindowController.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRSetupWindowController.h"
#import "SRSubredditDataStore.h"
#import "SRWallpaperChanger.h"
#import "Snappr-Swift.h"

@interface SRSetupWindowController ()

@end

@implementation SRSetupWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self showGeneralTab:self];
}

- (IBAction)showGeneralTab:(id)sender {
    self.window.toolbar.selectedItemIdentifier = @"general";
    
    self.settingsViewController = [[SRGeneralSettingsViewController alloc] init];
    self.contentViewController = self.settingsViewController;
}

- (IBAction)showSubredditsTab:(id)sender {
    self.window.toolbar.selectedItemIdentifier = @"subreddits";
    
    self.settingsViewController = [[SRSubredditsSettingsViewController alloc] init];
    self.contentViewController = self.settingsViewController;
}

@end
