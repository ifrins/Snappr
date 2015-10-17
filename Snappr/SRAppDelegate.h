//
//  SRAppDelegate.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import "SRSetupWindowController.h"

@interface SRAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, SUUpdaterDelegate>

@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusItem;
@property (strong) SRSetupWindowController *settingsWindowController;

- (IBAction)nextWallpaper:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)viewCurrentWallpaper:(id)sender;

- (IBAction)showDonatePage:(id)sender;
- (IBAction)showFeedbackPage:(id)sender;

@end
