//
//  BFChatLogViewer.h
//  BlackFire
//
//  Created by Antwan van Houdt on 2/3/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>

@class BFChatLog, XFSession;

@interface BFChatLogViewer : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *chatlogView;
@property (unsafe_unretained) IBOutlet NSTableView *friendsList;
@property (unsafe_unretained) IBOutlet NSTableView *chatlogList;

@property (unsafe_unretained) XFSession *session;

- (IBAction)showWindow:(id)sender;

//----------------------------------------------------------------------------
// Toolbar

- (IBAction)cleanOldChatlogs:(id)sender;
- (IBAction)cleanAllChatlogs:(id)sender;
- (IBAction)saveChatlog:(id)sender;

//----------------------------------------------------------------------------
// Table view crap

- (IBAction)selectedAFriend:(id)sender;
- (IBAction)selectedAChat:(id)sender;

@end
