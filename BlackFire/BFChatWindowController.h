//
//  BFChatWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h> 
#import "SFTabStripView.h"
#import "XNResizingMessageView.h"

@class BFChat, NSNonRetardedImageView, XNResizingMessageView, XNBorderedScrollView;


@interface BFChatWindowController : NSObject <NSToolbarDelegate, TabStripDelegate, NSWindowDelegate, BFChatMessageViewDelegate>
{
	NSWindow	*_window;
	NSView		*_switchView;
	
	XNBorderedScrollView	*_messageScrollView;
	XNResizingMessageView	*_messageView;
	
	NSView *_toolbarView;
	NSToolbarItem *_toolbarItem;
	
	// chat toolbar
	NSNonRetardedImageView *_avatarImageView;
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

@property (assign) IBOutlet XNBorderedScrollView *messageScrollView;
@property (assign) IBOutlet XNResizingMessageView *messageView;

@property (assign) IBOutlet NSNonRetardedImageView *avatarImageView;
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

- (void)closeChat:(BFChat *)chat;
- (void)destroy;
- (void)tabShouldClose:(SFTabView *)tabView;
- (void)changeSwitchView:(NSView *)newView;

- (void)selectPreviousTab;
- (void)selectNextTab;

- (SFTabView *)tabViewForChat:(BFChat *)chat;


//----------------------------------------------------------------------
// User interface controls

/*
 * Updates the toolbar information using the currently selected chat
 * as its reference.
 */
- (void)updateToolbar;

@end
