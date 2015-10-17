//
//  SRSetupWindowController.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSetupWindowController : NSWindowController <NSTableViewDelegate>

@property NSViewController *settingsViewController;

- (IBAction)showGeneralTab:(id)sender;
- (IBAction)showSubredditsTab:(id)sender;

@end
