//
//  BFChatWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h> 
#import "SFTabStripView.h"

@class BFChat;


@interface BFChatWindowController : NSObject <TabStripDelegate, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
	NSWindow	*_window;
	NSView		*_switchView;
	NSTextField *_messageField;

	NSMutableArray	*_chats;
	BFChat			*_currentlySelectedChat;
	
	SFTabStripView *_tabStripView;
}

@property (assign) IBOutlet NSView *switchView;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *messageField;

@property (assign) IBOutlet SFTabStripView *tabStripView;

- (id)init;

//----------------------------------------------------------------------
// Managing chats
- (void)addChat:(BFChat *)chat;
- (void)tabShouldClose:(SFTabView *)tabView;
- (void)changeSwitchView:(NSView *)newView;


//----------------------------------------------------------------------
// User interface controls

- (IBAction)sendMessage:(id)sender;

@end
