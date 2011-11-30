//
//  ADAppDelegate.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFSession.h"

typedef enum
{
	BFApplicationModeOffline = 1,
	BFApplicationModeLoggingIn = 2,
	BFApplicationModeOnline = 3,
	BFApplicationModeGames = 4,
	BFApplicationModeServers = 5
} BFApplicationMode;

@class BFLoginViewController, BFFriendsListController, BFAccount, BFChatWindowController;

@interface ADAppDelegate : NSObject <NSToolbarDelegate, NSApplicationDelegate, XFSessionDelegate>
{
	XFSession				*_session;
	BFAccount				*_account;
	
	NSView			*_mainView;
	NSView			*_toolbarView;
	NSToolbarItem	*_toolbarItem;
	
	// toolbar outlets
	NSImageView *_avatarImageView;
	NSImageView *_statusBubbleView;
	NSPopUpButton *_nicknamePopUpButton;
	NSPopUpButton *_statusPopUpButton;
	// end toolbar outlets
	
	NSMutableArray *_chatControllers;
	
	BFLoginViewController	*_loginViewController;
	BFFriendsListController *_friendsListController;
	
	BFApplicationMode		_currentMode;
}

@property (readonly) XFSession *session;
@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSImageView *avatarImageView;
@property (assign) IBOutlet NSImageView *statusBubbleView;
@property (assign) IBOutlet NSPopUpButton *nicknamePopUpButton;
@property (assign) IBOutlet NSPopUpButton *statusPopUpButton;

@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSView *toolbarView;

@property (readonly) BFApplicationMode currentMode;

//----------------------------------------------------------------------------
// Managing the main window

- (void)changeToMode:(BFApplicationMode)newMode;
- (void)changeMainView:(NSView *)newView;

//----------------------------------------------------------------------------
// Xfire Session
- (void)connectionCheck;
- (void)disconnect;

- (void)beginChatWithFriend:(XFFriend *)remoteFriend;

//----------------------------------------------------------------------------
// Friends list toolbar

- (IBAction)selectStatus:(id)sender;
- (IBAction)selectNicknameOption:(id)sender;

@end
