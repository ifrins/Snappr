//
//  SRSetupWindowController.h
//  Snappr
//
//  Copyright (c) 2014 Snapr. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SRSetupWindowController : NSWindowController <NSTableViewDelegate>

@property IBOutlet NSTableView* subredditsTableView;
@property IBOutlet NSWindow* addModalWindow;
@property IBOutlet NSComboBox* subredditComboBox;

@property NSInteger refreshFrequency;


- (IBAction)addSubreddit:(id)sender;
- (IBAction)removeSubreddit:(id)sender;
- (IBAction)frequencyChanged:(id)sender;

- (IBAction)modalDismiss:(id)sender;
- (IBAction)modalAddSubreddit:(id)sender;

@end
