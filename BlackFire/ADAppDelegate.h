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

@property (readonly) XFSession			*session;
@property (unsafe_unretained) IBOutlet NSWindow	*window;

@property (unsafe_unretained) IBOutlet NSNonRetardedImageView	*avatarImageView;
@property (unsafe_unretained) IBOutlet NSImageView		*statusBubbleView;
@property (unsafe_unretained) IBOutlet NSPopUpButton	*nicknamePopUpButton;
@property (unsafe_unretained) IBOutlet NSPopUpButton	*statusPopUpButton;
@property (unsafe_unretained) IBOutlet NSButton		*rightExtraButton;

@property (unsafe_unretained) IBOutlet NSView *mainView;
@property (unsafe_unretained) IBOutlet NSView *toolbarView;
@property (unsafe_unretained) IBOutlet NSView *sidebarView;

@property (unsafe_unretained) IBOutlet NSSegmentedControl *addButton;
@property (unsafe_unretained) IBOutlet ADModeSwitchView *modeSwitch;

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
