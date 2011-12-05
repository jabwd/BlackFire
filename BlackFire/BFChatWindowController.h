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


@interface BFChatWindowController : NSObject <NSToolbarDelegate, TabStripDelegate, NSWindowDelegate>
{
	NSWindow	*_window;
	NSView		*_switchView;
	NSTextField *_messageField;
	
	NSView *_toolbarView;
	NSToolbarItem *_toolbarItem;
	
	// chat toolbar
	NSImageView *_avatarImageView;
	NSImageView *_statusIconView;
	NSTextField *_nicknameField;
	NSTextField *_statusField;
	// end chat toolbar

	NSMutableArray	*_chats;
	BFChat			*_currentlySelectedChat;
	
	SFTabStripView *_tabStripView;
}

@property (assign) IBOutlet NSView *switchView;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *messageField;

@property (assign) IBOutlet NSImageView *avatarImageView;
@property (assign) IBOutlet NSImageView *statusIconView;
@property (assign) IBOutlet NSTextField *nicknameField;
@property (assign) IBOutlet NSTextField *statusField;

@property (assign) IBOutlet NSView *toolbarView;

@property (assign) IBOutlet SFTabStripView *tabStripView;
@property (readonly) BFChat *currentChat;

- (id)init;

//----------------------------------------------------------------------
// Managing chats

- (void)selectChat:(BFChat *)chat;
- (void)addChat:(BFChat *)chat;
- (void)tabShouldClose:(SFTabView *)tabView;
- (void)changeSwitchView:(NSView *)newView;


//----------------------------------------------------------------------
// User interface controls

- (IBAction)sendMessage:(id)sender;

/*
 * Updates the toolbar information using the currently selected chat
 * as its reference.
 */
- (void)updateToolbar;

@end
