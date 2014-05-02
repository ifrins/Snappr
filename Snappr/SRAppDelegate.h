//
//  SRAppDelegate.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRSetupWindowController.h"

@interface SRAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property IBOutlet NSMenu* statusMenu;
@property NSStatusItem* statusItem;
@property SRSetupWindowController* settingsWindowController;

- (IBAction)nextWallpaper:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)openAbout:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)viewCurrentWallpaper:(id)sender;

@end
