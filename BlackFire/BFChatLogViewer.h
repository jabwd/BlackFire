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

@interface BFChatLogViewer : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
{
	NSMutableArray	*_friends;
	NSMutableArray	*_chats;
	
	BFChatLog		*_currentChatLog;
	
	NSTextView *_chatlogView;
	NSTableView *_friendsList;
	NSTableView *_chatlogList;
    
    sqlite3 *_currentDatabase;
    
    XFSession *_session;
}

@property (assign) IBOutlet NSTextView *chatlogView;
@property (assign) IBOutlet NSTableView *friendsList;
@property (assign) IBOutlet NSTableView *chatlogList;

@property (assign) XFSession *session;

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
