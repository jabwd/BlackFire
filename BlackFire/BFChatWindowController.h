//
//  BFChatWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h> 

@class BFChat;


@interface BFChatWindowController : NSObject <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
	NSWindow *_window;
	
	NSTableView *_messageTableView;

	NSMutableArray *_chats;
	BFChat	*_currentlySelectedChat;
}

@property (assign) IBOutlet NSTableView *messageTableView;
@property (assign) IBOutlet NSWindow *window;

- (id)init;

//----------------------------------------------------------------------
// Managing chats
- (void)addChat:(BFChat *)chat;

/*
 * Call this to refresh the tableview
 */
- (void)reloadData;

@end
