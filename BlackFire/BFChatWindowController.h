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

@property (unsafe_unretained) IBOutlet NSView *switchView;
@property (unsafe_unretained) IBOutlet NSWindow *window;

@property (unsafe_unretained) IBOutlet XNBorderedScrollView *messageScrollView;
@property (unsafe_unretained) IBOutlet XNResizingMessageView *messageView;

@property (unsafe_unretained) IBOutlet NSNonRetardedImageView *avatarImageView;
@property (unsafe_unretained) IBOutlet NSImageView *statusIconView;
@property (unsafe_unretained) IBOutlet NSTextField *nicknameField;
@property (unsafe_unretained) IBOutlet NSTextField *statusField;
@property (unsafe_unretained) IBOutlet NSView *backgroundView;

@property (unsafe_unretained) IBOutlet NSView *toolbarView;

@property (unsafe_unretained) IBOutlet SFTabStripView *tabStripView;
@property (unsafe_unretained, readonly) BFChat *currentChat;

- (id)init;

//----------------------------------------------------------------------
// Managing chats

- (void)selectChat:(BFChat *)chat;
- (void)addChat:(BFChat *)chat;

- (void)closeChat:(BFChat *)chat;
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
