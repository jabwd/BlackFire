//
//  ADAppDelegate.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFSession.h"

#import "BFGamesManager.h"
#import "BFDownload.h"
#import "ADStringPromptController.h"
#import "BFIdleTimeManager.h"

typedef enum
{
	BFApplicationModeOffline		= 1,
	BFApplicationModeLoggingIn		= 2,
	BFApplicationModeOnline			= 3,
	BFApplicationModeGames			= 4,
	BFApplicationModeServers		= 5,
	BFApplicationModeInformation	= 6
} BFApplicationMode;

@class BFLoginViewController, BFFriendsListController, BFAccount, BFChatWindowController, BFPreferencesWindowController, BFGamesListController, BFServerListController, ADModeSwitchView, NSNonRetardedImageView, BFChatLogViewer, BFInformationViewController;

@interface ADAppDelegate : NSObject <BFIdleTimeManagerDelegate,BFDownloadDelegate, ADStringPromptDelegate, BFGameDetectionDelegate ,NSToolbarDelegate, NSApplicationDelegate, XFSessionDelegate>
{
	NSWindow *_window;
	NSSegmentedControl *_addButton;
	ADModeSwitchView *_modeSwitch;
	
	XFSession				*_session;
	BFAccount				*_account;
	
	NSView			*_mainView;
	NSView			*_toolbarView;
	NSToolbarItem	*_toolbarItem;
	
	// toolbar outlets
	//NSImageView		*_avatarImageView;
	NSNonRetardedImageView *_avatarImageView;
	NSImageView		*_statusBubbleView;
	NSPopUpButton	*_nicknamePopUpButton;
	NSPopUpButton	*_statusPopUpButton;
	NSButton		*_rightExtraButton;
	NSView			*_sidebarView;
	// end toolbar outlets
	
	NSMutableArray *_chatControllers;
	NSMutableArray *_friendshipRequests;
	
	
	BFDownload		*_download;
	
	BFLoginViewController			*_loginViewController;
	BFFriendsListController			*_friendsListController;
	BFPreferencesWindowController	*_preferencesWindowController;
	BFGamesListController			*_gamesListController;
	BFInformationViewController		*_informationViewController;
	BFServerListController			*_serverListController;
	BFChatLogViewer					*_chatlogViewer;
	ADStringPromptController		*_stringPromptController;
	
	BFApplicationMode		_currentMode;
	
	BOOL _changingNickname;
}

@property (readonly) XFSession			*session;
@property (assign) IBOutlet NSWindow	*window;

@property (assign) IBOutlet NSNonRetardedImageView	*avatarImageView;
@property (assign) IBOutlet NSImageView		*statusBubbleView;
@property (assign) IBOutlet NSPopUpButton	*nicknamePopUpButton;
@property (assign) IBOutlet NSPopUpButton	*statusPopUpButton;
@property (assign) IBOutlet NSButton		*rightExtraButton;

@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSView *toolbarView;
@property (assign) IBOutlet NSView *sidebarView;

@property (assign) IBOutlet NSSegmentedControl *addButton;
@property (assign) IBOutlet ADModeSwitchView *modeSwitch;

@property (readonly) BFApplicationMode currentMode;

//----------------------------------------------------------------------------
// Managing the main window

- (void)changeToMode:(BFApplicationMode)newMode;
- (void)changeMainView:(NSView *)newView;
- (void)changeSidebarView:(NSView *)newView;
- (IBAction)modeControl:(id)sender;
- (IBAction)gamesMode:(id)sender;
- (IBAction)friendsMode:(id)sender;
- (IBAction)showFriendInformation:(id)sender;

//----------------------------------------------------------------------------
// Xfire Session

- (void)connectionCheck;
- (IBAction)disconnect:(id)sender;

- (void)beginChatWithFriend:(XFFriend *)remoteFriend;
- (void)requestAvatarForFriend:(XFFriend *)remoteFriend;

- (void)checkForFriendRequest;
- (void)startUserSearching:(NSString *)searchQuery;

//----------------------------------------------------------------------------
// Main menu

- (IBAction)showChatLogViewer:(id)sender;
- (IBAction)selectNextTab:(id)sender;
- (IBAction)selectPreviousTab:(id)sender;

- (IBAction)help:(id)sender;
- (IBAction)closeAction:(id)sender; // overrides the default close found in 
// in the file menu: close tab not the window


- (IBAction)showPreferences:(id)sender;
- (IBAction)showProfile:(id)sender;
- (IBAction)removeSelectedFriend:(id)sender;
- (IBAction)toggleShowOfflineClanFriends:(id)sender;
- (IBAction)toggleShowOfflineFriends:(id)sender;
- (IBAction)toggleShowFriendsOfFriends:(id)sender;
- (IBAction)toggleShowNicknames:(id)sender;
- (IBAction)toggleShowClans:(id)sender;

//----------------------------------------------------------------------------
// Friends list toolbar

- (IBAction)rightExtraButtonAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)showUserProfile:(id)sender;

- (IBAction)selectAvailable:(id)sender;
- (IBAction)selectAway:(id)sender;

- (IBAction)selectNicknameOption:(id)sender;

@end
