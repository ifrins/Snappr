//
//  SRSetupWindowController.m
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import "SRSetupWindowController.h"
#import "SRSubredditDataStore.h"
#import "SRWallpaperChanger.h"

@interface SRSetupWindowController ()

@end

@implementation SRSetupWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _refreshFrequency = [prefs integerForKey:@"refreshFrequency"] / 3600;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [_subredditsTableView setDelegate:self];
    [_subredditsTableView setDataSource:[SRSubredditDataStore sharedDatastore]];
    [_subredditsTableView reloadData];
}

- (IBAction)addSubreddit:(id)sender {
    [NSApp beginSheet: _addModalWindow
       modalForWindow: [self window]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow: _addModalWindow];
}

- (IBAction)removeSubreddit:(id)sender {
    NSInteger selectedRow = [_subredditsTableView selectedRow];
    [[SRSubredditDataStore sharedDatastore] removeSubreddit:selectedRow];
    [_subredditsTableView reloadData];
}

- (IBAction)frequencyChanged:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:(_refreshFrequency * 3600) forKey:@"refreshFrequency"];
    [prefs synchronize];
    
    [[SRWallpaperChanger sharedChanger] changeTimerWithNewRepetition:(_refreshFrequency * 3600)];
}

- (IBAction)modalDismiss:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet:_addModalWindow];
    [_addModalWindow orderOut:self];
}

- (IBAction)modalAddSubreddit:(id)sender {
    if (![[_subredditComboBox stringValue] isEqual:@""])
    {
        [[SRSubredditDataStore sharedDatastore] addSubreddit:[_subredditComboBox stringValue]];
    }
    
    [NSApp stopModal];
    [NSApp endSheet:_addModalWindow];
    [_addModalWindow orderOut:self];
    [_subredditsTableView reloadData];
}

@end
