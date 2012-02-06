//
//  BFChatLogViewer.h
//  BlackFire
//
//  Created by Antwan van Houdt on 2/3/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BFChatLog;

@interface BFChatLogViewer : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
	NSMutableArray	*_friends;
	NSMutableArray	*_chats;
	
	BFChatLog		*_currentChatLog;
}

@property (assign) IBOutlet NSTextView *chatlogView;
@property (assign) IBOutlet NSTableView *friendsList;
@property (assign) IBOutlet NSTableView *chatlogList;

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
