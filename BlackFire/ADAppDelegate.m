//
//  ADAppDelegate.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "ADAppDelegate.h"
#import "XFSession.h"
#import "XFFriend.h"
#import "XFChat.h"
#import "XFGroupController.h"
#import "XFGroup.h"

#import "BFAccount.h"

#import "BFLoginViewController.h"
#import "BFFriendsListController.h"
#import "BFGamesListController.h"
#import "BFPreferencesWindowController.h"
#import "BFServerListController.h"
#import "BFChatWindowController.h"
#import "BFChat.h"
#import "BFRequestWindowController.h"
#import "BFAddGameSheetController.h"
#import "BFInformationViewController.h"
#import "ADInvitationWindowController.h"
#import "BFChatLogViewer.h"
#import "BFInfoViewController.h"

#import "BFNotificationCenter.h"
#import "ADModeSwitchView.h"
#import "NSNonRetardedImageView.h"

#import "BFIdleTimeManager.h"
#import "BFApplicationSupport.h"
#import "BFSoundSet.h"

#import "BFDefaults.h"

@implementation ADAppDelegate
{
	BFAccount				*_account;
	NSToolbarItem	*_toolbarItem;
	
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
	
	BOOL _changingNickname;
}


+ (void)initialize
{
	NSNumber *n_true	= [[NSNumber alloc] initWithBool:true];
	NSNumber *n_false	= [[NSNumber alloc] initWithBool:false];
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  n_true,BFEnableNotifications,
						  n_true,BFEnableSendSound,
						  n_true,BFEnableReceiveSound,
						  n_true,BFReceiveSoundBackgroundOnly,
						  n_true,BFEnableConnectSound,
						  n_true,BFEnableFriendOnlineStatusSound,
						  n_true,BFShowClanGroups,
						  n_true,BFAutoGoAFK,
						  n_true,BFEnableChatHistory,
						  n_true,BFEnableChatlogs,
						  n_false,BFMessageFieldHistory,
						  n_true,BFDetectGames,
						  n_true,BFAutoUpdateGameDefinitions,
						  @1.0f,BFSoundVolume,
						  @120,BFAutoAFKTime,
						  nil];
	
	// register the defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	
}

- (void)dealloc
{
	_download = nil;
	[_session disconnect];
	_account = nil;
	_chatControllers = nil;
	_preferencesWindowController = nil;
	_friendshipRequests = nil;
	_chatlogViewer = nil;
}

- (void)awakeFromNib
{
	[[BFGamesManager sharedGamesManager] setDelegate:self];
	_chatControllers	= [[NSMutableArray alloc] init];
	_download			= nil;
	_preferencesWindowController = nil;
	
	
	
	// setup the mainwindow
	[self changeToMode:BFApplicationModeOffline];
	[_window setContentBorderThickness:30.0 forEdge:NSMinYEdge];
	[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
	
	NSToolbar*toolbar = [[NSToolbar alloc] initWithIdentifier:@"friendsListToolbar"];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setSizeMode:               NSToolbarSizeModeSmall];
    [toolbar setDisplayMode:            NSToolbarDisplayModeIconOnly];
    
    _toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"status"];
    [_toolbarItem setView:_toolbarView];
    [_toolbarItem setMinSize:NSMakeSize(168.0, NSHeight([_toolbarView frame]))];
    [_toolbarItem setMaxSize:NSMakeSize(1920.0, NSHeight([_toolbarView frame]))];
    
    [toolbar      setDelegate:self];
    [_window	setToolbar:toolbar];
	
	[_modeSwitch setTarget:self];
	[_modeSwitch setSelector:@selector(modeControl:)];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	// for awesome behaviour!
	if( [_chatControllers count] > 0 )
	{
		BFChat *targetChat = nil;
		NSUInteger top = 0;
		for(BFChat *chat in _chatControllers)
		{
			if( chat.missedMessages > 0 )
			{
				if( chat.missedMessages > top )
				{
					top = chat.missedMessages;
					targetChat = chat;
				}
			}
		}
		if( targetChat )
		{
			[targetChat.windowController selectChat:targetChat];
			[targetChat.windowController.window makeKeyAndOrderFront:self];
			return false;
		}
	}
	if( ![_window isVisible] )
	{
		[_window makeKeyAndOrderFront:self];
	}
	return false;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	NSUInteger i, cnt = [_chatControllers count];
	for(i=0;i<cnt;i++)
	{
		[_chatControllers[0] closeChat];
	}
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	return nil;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self connectionCheck];
	[[BFIdleTimeManager defaultManager] setDelegate:self];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	NSString *folderPath = BFSoundsetsDirectoryPath();
	for(NSString *file in filenames)
	{
		if( [file hasSuffix:@".BlackFireSnd"] || [file hasSuffix:@"AdiumSoundset"] || [file hasSuffix:@"AdiumSoundSet"] || [file hasSuffix:@".BlackFireSoundset"] || [file hasSuffix:@".BlackFireSoundSet"] )
		{
			[[NSFileManager defaultManager] copyItemAtPath:file toPath:[NSString stringWithFormat:@"%@/%@",folderPath,[file lastPathComponent]] error:nil];
			BFSoundSet *set = [[BFSoundSet alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",folderPath,[file lastPathComponent]]];
			if( set )
			{
				NSString *name = set.name;
				if( ! name )
					name = @"Untitled soundset";
				NSInteger result = NSRunAlertPanel(NSLocalizedString(@"Soundset installed",@"Soundset installed"), [NSString stringWithFormat:NSLocalizedString(@"Soundset %@ was successfully installed",@"Soundset installed message"),name], NSLocalizedString(@"Set as default soundset", @"Set as default soundset"), NSLocalizedString(@"OK",@"OK"), nil);
				if( result == NSOKButton )
				{
					[[BFNotificationCenter defaultNotificationCenter] setSoundSet:set];
					[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@/%@",folderPath,[file lastPathComponent]] forKey:BFSoundSetPath];
				}
			}
			else
			{
				NSRunAlertPanel(@"Error", @"Could not open this soundset, sorry! :/", @"OK", nil, nil);
			}
		}
		else
		{
			NSURL *URL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@",file]]];
			NSString *message = nil;
			NSString *secondButton = nil;
			if( URL )
			{
				NSString *appname = [[URL relativePath] lastPathComponent];
				appname = [appname stringByReplacingOccurrencesOfString:@".app" withString:@""];
				message = [NSString stringWithFormat:@"The file you tried to open with BlackFire is unsupported by BlackFire. However it seems that %@ is able to open your file.",appname];
				secondButton = [NSString stringWithFormat:@"Open with %@",appname];
			}
			if( ! message )
				message = @"BlackFire cannot open this file.";
			NSInteger result = NSRunAlertPanel(@"Unrecognized file", message, @"OK", secondButton, nil);
			if( result == NSCancelButton && [secondButton length] > 0 )
			{
				[[NSWorkspace sharedWorkspace] openFile:file];
			}
		}
	}
}

#pragma mark - Toolbar delegate
- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag 
{
	return _toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar 
{
	return @[@"status"];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar 
{
	return @[@"status"];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem 
{
	return YES;
}

#pragma mark - Managing the main window

- (void)changeToMode:(BFApplicationMode)newMode
{
	// computer says no.
	if( _currentMode == newMode )
		return;
	
	switch(newMode)
	{
		case BFApplicationModeOffline:
		{
			// make sure that all string prompts currently visible are hidden:
			if( _stringPromptController )
			{
				[_stringPromptController hide];
				_stringPromptController = nil;
			}
			
			[_addButton setHidden:true];
			[_modeSwitch setHidden:true];
			
			if( ! _loginViewController )
			{
				_loginViewController = [[BFLoginViewController alloc] init];
				_loginViewController.delegate = self;
			}
			_friendsListController = nil;
			[_loginViewController session:_session changedStatus:XFSessionStatusOffline];
			
			[_statusBubbleView setImage:nil];
			[_avatarImageView setImage:nil];
			
			[_statusPopUpButton setTitle:@"Offline"];
			[_nicknamePopUpButton setTitle:@""];
			[_statusPopUpButton selectItemWithTag:0];
			[_rightExtraButton setHidden:true];
			[self changeMainView:_loginViewController.view];
			[self changeSidebarView:_loginViewController.infoViewController.view];
		}
			break;
			
		case BFApplicationModeLoggingIn:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusConnecting];
			[_statusPopUpButton setTitle:@"Connecting…"];
			[_rightExtraButton setHidden:true];
		}
			break;
			
		case BFApplicationModeOnline:
		{
			[_addButton setHidden:false];
			[_modeSwitch setHidden:false];
			[_loginViewController session:_session changedStatus:XFSessionStatusOnline];
			
			if( ! _friendsListController )
			{
				_friendsListController = [[BFFriendsListController alloc] init];
				_friendsListController.delegate = self;
			}
			
			[self changeMainView:_friendsListController.view];
			
			[_friendsListController reloadData];
			[_friendsListController.view setNeedsDisplay:true];
			[_rightExtraButton setHidden:true];
			[_modeSwitch selectItemAtIndex:0];
			[self changeSidebarView:_friendsListController.infoViewController.view];
		}
			break;
			
		case BFApplicationModeGames:
		{
			if( ! _gamesListController )
			{
				_gamesListController = [[BFGamesListController alloc] init];
			}
			[_gamesListController expandItem];
			[_gamesListController reloadData];
			
			[self changeMainView:_gamesListController.view];
			[_rightExtraButton setHidden:true];
			[_modeSwitch selectItemAtIndex:1];
			[self changeSidebarView:_gamesListController.infoViewController.view];
		}
			break;
			
		case BFApplicationModeServers:
		{
			if( ! _serverListController )
			{
				_serverListController = [[BFServerListController alloc] initWithSession:_session];
			}
			_serverListController.session = _session;
			[self changeMainView:_serverListController.view];
			
			[_rightExtraButton setHidden:false];
			[_modeSwitch selectItemAtIndex:2];
			[self changeSidebarView:_serverListController.infoViewController.view];
		}
			break;
			
		case BFApplicationModeInformation:
		{
			if( ! _informationViewController )
			{
				_informationViewController = [[BFInformationViewController alloc] init];
			}
			[_informationViewController setFriend:[_friendsListController selectedFriend]];
			[self changeMainView:_informationViewController.view];
			[_rightExtraButton setHidden:true];
			[_modeSwitch selectItemAtIndex:-1];
		}
			break;
			
		default:
		{
			NSLog(@"Cannot switch to unknown BFApplication mode");
		}
			break;
	}
	
	_currentMode = newMode;
}

- (void)changeMainView:(NSView *)newView
{
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:0.100f];
	[[NSAnimationContext currentContext] setCompletionHandler:^{
		NSArray *subviews = [_mainView subviews];
		for(NSView *view in subviews)
		{
			[view removeFromSuperview];
		}
		
		[_mainView addSubview:newView];
		[newView setFrame:[_mainView bounds]];
		[[_mainView animator] setAlphaValue:1.0f];
	}];
	[[_mainView animator] setAlphaValue:0.0f];
	[NSAnimationContext endGrouping];
}

- (void)changeSidebarView:(NSView *)newView
{
	NSArray *subviews = [_sidebarView subviews];
	for(NSView *view in subviews)
	{
		[view removeFromSuperview];
	}
	if( ! newView ) return;
	
	[_sidebarView addSubview:newView];
	[newView setFrame:[_sidebarView bounds]];
}

- (IBAction)modeControl:(id)sender
{
	NSInteger tag = [(ADModeSwitchView *)sender selectedItemIndex];
	if( tag == 0 )
	{
		[self changeToMode:BFApplicationModeOnline];
	}
	else if( tag == 1 )
	{
		[self changeToMode:BFApplicationModeGames];
	}
	else
	{
		[self changeToMode:BFApplicationModeServers];
	}
}

- (IBAction)friendsMode:(id)sender
{
	if( _session.status != XFSessionStatusOnline )
		return;
	
	[self changeToMode:BFApplicationModeOnline];
}

- (IBAction)gamesMode:(id)sender
{
	if( _session.status != XFSessionStatusOnline )
		return;
	
	[self changeToMode:BFApplicationModeGames];
}

- (IBAction)showFriendInformation:(id)sender
{
	XFFriend *friend = [_friendsListController selectedFriend];
	if( friend )
	{
		DLog(@"[Notice] Opening information view controller for %@",friend);
		[self changeToMode:BFApplicationModeInformation];
	}
	else {
		DLog(@"[Notice] Cannot open the information view controller with an empty friend");
	}
}

#pragma mark - Xfire Session

- (void)beginChatWithFriend:(XFFriend *)remoteFriend
{
	for(BFChat *chat in _chatControllers)
	{
		if( chat.chat.remoteFriend.userID == remoteFriend.userID )
		{
			// chat already exists
			// however, the user double clicked on the friends list, for awesome behaviour:
			// show the chat window on top, select the correct tab.
			[chat.windowController.window makeKeyAndOrderFront:nil];
			[chat.windowController selectChat:chat];
			return; // done here.
		}
	}
	[_session beginNewChatForFriend:remoteFriend];
	
	// now, the user clicked on the friend so we should make the chat window
	// the mainwindow again, exact same code as above.
	
	for(BFChat *chat in _chatControllers)
	{
		if( chat.chat.remoteFriend.userID == remoteFriend.userID )
		{
			// however, the user double clicked on the friends list, for awesome behaviour:
			// show the chat window on top, select the correct tab.
			[chat.windowController.window makeKeyAndOrderFront:nil];
			[chat.windowController selectChat:chat];
			
			return; // if there are more objects in the loop we optimize it a little bit here.
		}
	}
}

- (void)session:(XFSession *)session chatDidEnd:(XFChat *)chat
{
	NSUInteger i, cnt = [_chatControllers count];
	for(i=0;i<cnt;i++)
	{
		BFChat *bfchat = _chatControllers[i];
		if( bfchat.chat.remoteFriend.userID == chat.remoteFriend.userID )
		{
			[_chatControllers removeObjectAtIndex:i];
			return;
		}
	}
}

- (void)session:(XFSession *)session chatDidStart:(XFChat *)chat
{
	BFChatWindowController *chatController;
	if( [_chatControllers count] > 0 )
	{
		chatController = [_chatControllers[0] windowController];
	}
	else
	{
		chatController = [[BFChatWindowController alloc] init];
	}
	
	BFChat *blackfireChat = [[BFChat alloc] initWithChat:chat];
	[chatController addChat:blackfireChat];
	[chat setDelegate:blackfireChat];
	
	// not leaking, releases itself.
	
	[_chatControllers addObject:blackfireChat];
}




- (void)connectionCheck
{
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"];
	if( [username length] < 1 )
		return;
	_account = [[BFAccount alloc] initWithUsername:username];
	if( (!_session || _session.status == XFSessionStatusOffline) && [_account.username length] > 0 && [_account.password length] > 0  )
	{
		_session = [[XFSession alloc] initWithDelegate:self];
		[_session connect];
	}
	else
	{
		NSLog(@"Cannot connect at this time");
	}
}

- (IBAction)disconnect:(id)sender
{
	[_session disconnect];
	[_session setDelegate:nil];
	_session = nil;
	
	[self changeToMode:BFApplicationModeOffline];
}



- (void)session:(XFSession *)session friendChanged:(XFFriend *)changedFriend type:(XFFriendNotification)notificationType
{
	if( ! changedFriend )
	{
		// just make sure we are up-to-date then.
		[_friendsListController reloadData];
		return;
	}
	
	
	
	if( notificationType == XFFriendNotificationOnlineStatusChanged && [[changedFriend displayName] length] > 0 )
	{
		if( changedFriend.online )
		{
			[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:@"Friend came online" body:[NSString stringWithFormat:@"%@ came online",[changedFriend displayName]]];
			[[BFNotificationCenter defaultNotificationCenter] playOnlineSound];
			//[_friendsListController friendCameOnline:changedFriend];
			//	[_friendsListController friendCameOnline:changedFriend];
			//[_friendsListController.friendsList endUpdates];
		}
		else
		{
			[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:@"Friend went offline" body:[NSString stringWithFormat:@"%@ went offline",[changedFriend displayName]]];
			[[BFNotificationCenter defaultNotificationCenter] playOfflineSound];
		}
		[_friendsListController reloadData];
	}
	else if( notificationType == XFFriendNotificationFriendWillComeOnline )
	{
		//[_friendsListController.friendsList beginUpdates];
	}
	else if( notificationType == XFFriendNotificationFriendWillGoOffline )
	{
		//[_friendsListController.friendsList beginUpdates];
	}
	else if( notificationType == XFFriendNotificationStatusChanged )
	{
		//[[_session.groupController onlineFriendsGroup] sortMembers];
		[_friendsListController reloadData];
	}
	else
	{
		[_friendsListController reloadData];
	}
	
	// now post an application wide notification so other classes can update their shit too
	// ( mainly for the chat anyways ).
	NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:notificationType],@"type", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:XFFriendDidChangeNotification object:changedFriend userInfo:userInfo];
	
	// done with it.
}

- (void)session:(XFSession *)session loginFailed:(XFLoginError)reason
{
	if( reason == XFLoginErrorNetworkError )
	{
		NSRunAlertPanel(@"Login failed", @"Could not connect to xfire. Are you sure you are connected to the internet?", @"OK", nil, nil);
	}
	else if( reason == XFLoginErrorInvalidPassword )
	{
		NSRunAlertPanel(@"Login failed", @"Incorrect username and or password", @"OK", nil, nil);
	}
	else
	{
		NSRunAlertPanel(@"Error", [NSString stringWithFormat:@"An error occured %u",reason], @"OK", nil, nil);
	}
	
	[self changeToMode:BFApplicationModeOffline];
}

- (void)session:(XFSession *)session willDisconnectWithReason:(XFConnectionError)reason
{
	if( reason == XFConnectionErrorHungUp )
	{
		//NSRunAlertPanel(@"Disconnected", @"The Xfire server closed the connection. Either you are very naughty or something nasty happened. Try reconnecting.", @"OK", nil, nil);
	}
	else if( reason == XFConnectionErrorOtherSession )
	{
		//NSRunAlertPanel(@"Disconnected", @"Someone logged in on your account on another computer. If this wasn't you you should consider changing your password.", @"OK", nil, nil);
	}
	else if( reason == XFConnectionErrorStoppedResponding )
	{
		//NSRunAlertPanel(@"Server stopped responding", @"The Xfire server stopped responding. Try to reconnect, it usually is just a temporary problem.", @"OK", nil, nil);
	}
}



- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus
{
	if( newStatus == XFSessionStatusOnline )
	{
		[_statusBubbleView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
		[_avatarImageView setImage:[NSImage imageNamed:@"xfire"]];
		
		[_statusPopUpButton setTitle:@"Available"];
		NSString *nickname = [[_session loginIdentity] displayName];
		if( ! nickname )
			nickname = @":D"; // this should actually never ever happen
		[_nicknamePopUpButton setTitle:nickname];
		[[BFGamesManager sharedGamesManager] startMonitoring];
		[self changeToMode:BFApplicationModeOnline];
		
		[_friendsListController expandItem:[_session.groupController onlineFriendsGroup]];
		[_session requestFriendInformation:_session.loginIdentity];
		
		[[BFNotificationCenter defaultNotificationCenter] playConnectedSound];
	}
	else if( newStatus == XFSessionStatusConnecting )
	{
		[self changeToMode:BFApplicationModeLoggingIn];
	}
	else if( newStatus == XFSessionStatusDisconnecting )
	{
		// pre disconnect stage, get rid of the XFSession required resources here.
		NSUInteger i, cnt = [_chatControllers count];
		for(i=0;i<cnt;i++)
		{
			// this should work as the BFChat object is removed from the array when we call closeChat
			BFChat *chat = _chatControllers[0];
			[chat.windowController closeChat:chat];
		}
		[[BFGamesManager sharedGamesManager] stopMonitoring];
		_friendsListController.delegate = nil;
		[_friendsListController reloadData];
		_friendsListController = nil;
		[self changeToMode:BFApplicationModeOffline];
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		[_session setDelegate:nil];
		_session = nil;
	}
}



- (void)session:(XFSession *)session didReceiveFriendShipRequests:(NSArray *)requests
{
	_friendshipRequests = [[NSMutableArray alloc] initWithArray:requests];
	
	[self checkForFriendRequest];
}

- (void)checkForFriendRequest
{
	if( ! _stringPromptController )
	{
		XFFriend *requestFriend = _friendshipRequests[0];
		if( requestFriend )
		{
			_stringPromptController = [[BFRequestWindowController alloc] initWithWindow:self.window];
			[(BFRequestWindowController *)_stringPromptController fillWithXfireFriend:requestFriend];
			[_stringPromptController show];
			_stringPromptController.delegate = self;
		}
		[_friendshipRequests removeObjectAtIndex:0];
		if( [_friendshipRequests count] == 0 )
		{
			_friendshipRequests = nil;
		}
	}
}

- (void)session:(XFSession *)session didReceiveSearchResults:(NSArray *)results
{
	if( [_stringPromptController isKindOfClass:[ADInvitationWindowController class]] )
	{
		ADInvitationWindowController *controller = (ADInvitationWindowController *)_stringPromptController;
		[controller setSearchResults:[NSMutableArray arrayWithArray:results]];
		[controller reloadData];
	}
}

- (void)startUserSearching:(NSString *)searchQuery
{
	[_session beginUserSearch:searchQuery];
}




- (void)session:(XFSession *)session receivedAvatarInformation:(unsigned int)userID getValue:(unsigned int)getValue type:(unsigned int)type
{
	//	http://media.xfire.com/xfire/xf/images/avatars/gallery/default/492.gif
	//	http://www.xfire.com/avatar/160/username.jpg?getValue
	//  #define GALLERY_AVATAR_URL @"http://media.xfire.com/xfire/xf/images/avatars/gallery/default/%.3d.gif"
	//	#define DEFAULT_AVATAR_URL @"http://media.xfire.com/xfire/xf/images/avatars/gallery/default/xfire100.jpg"
	//	#define CUSTOM_AVATAR_URL  @"http://screenshot.xfire.com/avatar/100/%@.jpg?%d"
	XFFriend *remoteFriend = [_session friendForUserID:userID];
	if( ! remoteFriend && userID == _session.loginIdentity.userID )
		remoteFriend = _session.loginIdentity;
	
	NSURL *url = nil;

	switch(type)
	{
		case 0x01:
		{
			// stock xfire avatar
			url = [NSURL URLWithString:[NSString stringWithFormat:@"http://media.xfire.com/xfire/xf/images/avatars/gallery/default/%u.gif",getValue]];
		}
			break;
			
		case 0x02:
		{
			// uploaded avatar
			url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.xfire.com/avatar/160/%@.jpg?%u",remoteFriend.username,getValue]];
		}
			break;
			
		default:
			// no avatar.
			remoteFriend.avatar = [NSImage imageNamed:@"xfire"];
			return;
			break;
	}
	
	// only allow the download if its possible at this time
	if( !_download )
	{
		_download = [BFDownload avatarDownload:url withDelegate:self];
		_download.context = remoteFriend;
	}
}


- (void)session:(XFSession *)session nicknameChanged:(NSString *)newNickname
{
	[_nicknamePopUpButton setTitle:newNickname];
	[_friendsListController reloadData];
}

- (void)session:(XFSession *)session userStatusChanged:(NSString *)newStatus
{
	[_statusPopUpButton setTitle:newStatus];
	[_friendsListController reloadData];
	
	if( [newStatus length] > 1 && [newStatus rangeOfString:@"AFK"].length > 0 )
	{
		[_statusBubbleView setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
	}
	else
	{
		[_statusBubbleView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
	}
}


- (NSString *)username
{
	return [_account.username lowercaseString];
}

- (NSString *)password
{
	return _account.password;
}


#pragma mark - BFDownload

- (void)download:(BFDownload *)download didFailWithError:(NSError *)error
{
	_download = nil;
	NSLog(@"*** Unable to download avatar image %@",error);
}

- (void)download:(BFDownload *)download didFinishWithPath:(NSString *)path
{
	_download = nil;
	XFFriend *remoteFriend = (XFFriend *)download.context;
	if( remoteFriend )
	{
		NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
		NSString *imagePath = [[NSString alloc] initWithFormat:@"%@/com.exurion.BlackFire/%@.jpg",cachePath,remoteFriend.username];
		
		if( [[NSFileManager defaultManager] fileExistsAtPath:imagePath] )
			[[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
		
		[[NSFileManager defaultManager] moveItemAtPath:path toPath:imagePath error:nil];
		
		NSImage *avatarImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
		[avatarImage setScalesWhenResized:true];
		remoteFriend.avatar = avatarImage;
		
		if( remoteFriend.userID == _session.loginIdentity.userID && avatarImage )
		{
			NSImage *userImage = [avatarImage copy];
			[userImage setScalesWhenResized:true];
			[userImage setSize:NSMakeSize(32, 32)]; // make sure that the image view resizes the image to its own size
			[_avatarImageView setImage:userImage];
			
		}
		
	}
	
	[_friendsListController reloadData];
}

- (void)requestAvatarForFriend:(XFFriend *)remoteFriend
{
	[_session requestFriendInformation:remoteFriend];
}



#pragma mark - Game detection

- (void)gameDidLaunch:(unsigned int)gameID
{
	[_session enterGame:gameID IP:0 port:0];
}

- (void)gameDidTerminate:(unsigned int)gameID
{
	[_session exitGame];
}

- (void)gameIconDidDownload
{
	if( _gamesListController && _currentMode == BFApplicationModeGames )
	{
		[_gamesListController reloadData];
	}
	else
	{
		[_friendsListController reloadData];
	}
}

#pragma mark - Friends list toolbar

- (IBAction)showUserProfile:(id)sender
{
	// actually never happens, but just to be sure ( we don't want a (NULL) in the URL now do we! ).
	if( [_session.loginIdentity.username length] < 1 )
		return;
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.xfire.com/profile/%@",_session.loginIdentity.username]]];
}


- (IBAction)selectAvailable:(id)sender
{
	if( _session.status == XFSessionStatusOnline )
	{
		[_session setStatusString:@""];
		[_statusPopUpButton setTitle:@"Available"];
	}
	else {
		[self connectionCheck];
	}
}

- (IBAction)selectAway:(id)sender
{
	if( _session.status == XFSessionStatusOnline )
	{
		[_session setStatusString:@"(AFK) Away from keyboard"];
		[_statusPopUpButton setTitle:@"Away"];
	}
}

- (IBAction)selectCustomStatus:(id)sender
{
	if( _session.status != XFSessionStatusOnline )
		return;
	
	if( _stringPromptController )
	{
		NSLog(@"*** Cannot change status while another string prompt is running");
	}
	else
	{
		_changingNickname = false;
		_stringPromptController = [[ADStringPromptController alloc] initWithWindow:_window];
		NSString *status = _session.loginIdentity.status;
		if( ! status )
			status = @"";
		_stringPromptController.messageField.stringValue = status;
		_stringPromptController.titleField.stringValue = @"Change your status:";
		_stringPromptController.delegate = self;
		[_stringPromptController show];
	}
}

- (IBAction)selectNicknameOption:(id)sender
{
	if( _session.status != XFSessionStatusOnline )
		return;
	
	if( _stringPromptController )
	{
		NSLog(@"*** Cannot change nickname while another string prompt is running");
	}
	else
	{
		_changingNickname = true;
		_stringPromptController = [[ADStringPromptController alloc] initWithWindow:_window];
		NSString *nickname = _session.loginIdentity.nickname;
		if( ! nickname )
			nickname = @"";
		_stringPromptController.messageField.stringValue = nickname;
		_stringPromptController.titleField.stringValue = @"Change your nickname:";
		_stringPromptController.delegate = self;
		[_stringPromptController show];
	}
}


#pragma mark - String prompt

- (void)stringPromptDidSucceed:(ADStringPromptController *)prompt
{	
	// determine what kind of prompt it was.
	if( [prompt isKindOfClass:[BFRequestWindowController class]] )
	{
		XFFriend *remoteFriend = [(BFRequestWindowController *)prompt remoteFriend];
		[_session acceptFriendRequest:remoteFriend];
		_stringPromptController = nil;
		[self checkForFriendRequest];
		return;
	}
	else if( [prompt isKindOfClass:[ADInvitationWindowController class]] )
	{
		XFFriend *selectedFriend = [(ADInvitationWindowController *)prompt selectedFriend];
		if( selectedFriend )
		{
			[_session sendFriendRequest:selectedFriend.username message:prompt.messageField.stringValue];
		}
		_stringPromptController = nil;
		return;
	}
	else if( [prompt isKindOfClass:[BFAddGameSheetController class]] )
	{
		BFAddGameSheetController *controller = (BFAddGameSheetController *)_stringPromptController;
		NSString *appPath = controller.dropField.applicationPath;
		BOOL isDir = false;
		if( [[NSFileManager defaultManager] fileExistsAtPath:appPath isDirectory:&isDir] && isDir && [appPath hasSuffix:@".app"] )
		{
			NSDictionary *appInfo = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist",appPath]];
			NSString *detectionKey = nil;
			NSString *appName = [[appPath lastPathComponent] componentsSeparatedByString:@"."][0];
			if( ! appInfo )
			{
				NSLog(@"No information property list was found!");
			}
			else
			{
				detectionKey = appInfo[(NSString *)kCFBundleIdentifierKey];
			}
			if( ! detectionKey )
				detectionKey = appName;
			NSUInteger gameID = [_gamesListController selectedGameID];
			if( gameID > 0 )
			{
				NSDictionary *detectionDict = [[NSDictionary alloc] initWithObjectsAndKeys:appName,@"AppName",@(gameID),@"gameID", nil];
				// add the detection set to the custom mac games in the user defaults.
				[[BFGamesManager sharedGamesManager] addMacGame:detectionDict forKey:detectionKey];
				[_gamesListController reloadMacGames];
				[[BFGamesManager sharedGamesManager] reCheckRunningGames];
			}
		}
		_stringPromptController = nil;
		return;
	}
	
	NSString *nickname = [_stringPromptController.messageField.stringValue copy];
	_stringPromptController = nil;
	
	if( [nickname length] > 100 )
	{
		if( _changingNickname )
			NSRunAlertPanel(@"incorrect nickname", @"The nickname you chose was too long. Your old nickname has been restored.", @"OK", nil, nil);
		else
			NSRunAlertPanel(@"incorrect status", @"The status you entered is too long. Please choose one that is shorter.", @"OK", nil, nil);
		return;
	}
	else if( [nickname length] < 1 )
	{
		return;
	}
	
	if( _changingNickname )
	{
		[_session setNickname:nickname];
		_changingNickname = false;
	}
	else
	{
		[_session setStatusString:nickname];
	}
	
}

- (void)stringPromptDidCancel:(ADStringPromptController *)prompt
{
	// determine what kind of prompt it was.
	if( [prompt isKindOfClass:[BFRequestWindowController class]] )
	{
		XFFriend *remoteFriend = [(BFRequestWindowController *)prompt remoteFriend];
		[_session declineFriendRequest:remoteFriend];
		_stringPromptController = nil;
		[self checkForFriendRequest];
		return;
	}
	
	_stringPromptController = nil;
}

- (void)stringPromptDidDefer:(ADStringPromptController *)prompt
{
	_stringPromptController = nil;
	[self checkForFriendRequest];
}

- (void)setSessionStatusString:(NSString *)status
{
	if( status > 0 )
		[_session setStatusString:status];
}

- (NSString *)sessionStatusString
{
	return [_session loginIdentity].status;
}

#pragma mark - Custom status

- (void)userWentAway
{
	if( _session.status == XFSessionStatusOnline && [_session.loginIdentity.status length] < 1 )
	{
		[_session setStatusString:@"(AFK) Away from keyboard"];
		[_statusPopUpButton setTitle:@"Away"];
	}
}

- (void)userBecameActive
{
	if( _session.status == XFSessionStatusOnline && [_session.loginIdentity.status length] > 1 )
	{
		[_session setStatusString:@""];
		[_statusPopUpButton setTitle:@"Available"];
	}
}


#pragma mark - Menu items

- (IBAction)showChatLogViewer:(id)sender
{
	if( _chatlogViewer ){
		[_chatlogViewer showWindow:nil];
		return;
	}
	_chatlogViewer = [[BFChatLogViewer alloc] init];
	[_chatlogViewer showWindow:nil];
    [_chatlogViewer setSession:_session];
}

- (IBAction)rightExtraButtonAction:(id)sender
{
	if( _currentMode == BFApplicationModeServers )
	{
		[_serverListController refreshAll:sender];
	}
}

- (IBAction)addAction:(id)sender
{
	if( ! _stringPromptController && _session.status == XFSessionStatusOnline )
	{
		NSInteger idx = [_addButton selectedSegment];
		switch(idx)
		{
			case 0:
			{
				if( _currentMode == BFApplicationModeGames )
				{
					if( [_gamesListController selectedGameID] > 0 )
					{
						_stringPromptController = [[BFAddGameSheetController alloc] initWithWindow:self.window];
						_stringPromptController.delegate = self;
						[_stringPromptController show];
					}
					else
					{
						NSBeep();
					}
					return;
				}
				_stringPromptController = [[ADInvitationWindowController alloc] initWithWindow:self.window];
				_stringPromptController.delegate = self;
				[_stringPromptController show];
			}
				break;
				
			case 1:
			{
				[self removeSelectedFriend:nil];
			}
				break;
		}
	}
}

- (IBAction)selectNextTab:(id)sender
{
	// detect if a window is in front
	for(BFChat *chat in _chatControllers)
	{
		NSWindow *window = chat.windowController.window;
		if( [window isMainWindow] )
		{
			[chat.windowController selectNextTab];
			return;
		}
	}
}

- (IBAction)selectPreviousTab:(id)sender
{
	for(BFChat *chat in _chatControllers)
	{
		NSWindow *window = chat.windowController.window;
		if( [window isMainWindow] )
		{
			[chat.windowController selectPreviousTab];
			return;
		}
	}
}

- (IBAction)closeAction:(id)sender
{
	for(BFChat *chat in _chatControllers)
	{
		NSWindow *window = chat.windowController.window;
		if( [window isMainWindow] && chat.windowController.currentChat == chat )
		{
			[chat.windowController closeChat:chat];
			return;
		}
	}
	if( [[NSApplication sharedApplication] mainWindow] )
	{
		[[[NSApplication sharedApplication] mainWindow] performClose:nil];
	}
}

- (IBAction)showPreferences:(id)sender
{
	// don't know if i should ever release this, because the user loaded it once
	// and there is no real reason to get rid of it then..
	if( _preferencesWindowController )
	{
		[_preferencesWindowController showWindow:nil];
	}
	else
	{
		_preferencesWindowController = [[BFPreferencesWindowController alloc] init];
		[_preferencesWindowController showWindow:nil];
	}
}

- (IBAction)showProfile:(id)sender
{
	XFFriend *selectedFriend = [_friendsListController selectedFriend];
	if( selectedFriend )
	{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.xfire.com/profile/%@",selectedFriend.username]]];
	}
}

- (IBAction)removeSelectedFriend:(id)sender
{
	if( ![_window isMainWindow] )
	{
		return;
	}
	XFFriend *selectedFriend = [_friendsListController selectedFriendNotFoF];
	if( ! selectedFriend || selectedFriend.clanFriend || selectedFriend.friendOfFriend )
		return;
	
	NSUInteger result = NSRunAlertPanel([NSString stringWithFormat:@"Are you sure you want to delete %@",[selectedFriend displayName]], @"This will permanently delete him or her from your friends list", @"OK", @"Cancel", nil);
	if( result == NSOKButton )
	{
		[_session sendRemoveFriend:selectedFriend];
	}
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	switch([menuItem tag])
	{
		case 2:
		{
			// previous stab
			if( [_chatControllers count] > 0 )
			{
				return true;
			}
		}
			break;
			
		case 3:
		{
			// next tab
			if( [_chatControllers count] > 0 )
			{
				return true;
			}
		}
			break;
			
		case 4:
		{
			// remove friend
			XFFriend *selectedFriend = [_friendsListController selectedFriend];
			if( !selectedFriend.clanFriend && !selectedFriend.friendOfFriend && selectedFriend )
				return true;
		}
			break;
			
		case 5:
		{
			// show profile
			if( [_friendsListController selectedOnlineFriend] )
				return true;
		}
			break;
			
		case 6: // Account controls
		{
			if( _session.status == XFSessionStatusOnline )
				return true;
		}
			break;
			
		case 7: // show / hide clan friend groups
		{
			if( _session.status != XFSessionStatusOnline )
				return false;
			
			if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowClanGroups] )
			{
				[menuItem setTitle:@"Hide clans"];
			}
			else
			{
				[menuItem setTitle:@"Show clans"];
			}
			
			return true;
		}
			break;
			
		case 8: // show / hide custom friend groups
			break;
			
		case 9: // show / hide offline friends group
		{
			if( _session.status != XFSessionStatusOnline )
				return false;
			
			if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowOfflineFriendsGroup] )
			{
				[menuItem setTitle:@"Hide offline friends"];
			}
			else
			{
				[menuItem setTitle:@"Show offline friends"];
			}
			return true;
		}
			break;
			
		case 10: // show / hide offline clan friends
		{
			if( _session.status != XFSessionStatusOnline )
				return false;
			
			if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowOfflineClanFriends] )
			{
				[menuItem setTitle:@"Hide offline clan friends"];
			}
			else 
			{
				[menuItem setTitle:@"Show offline clan friends"];
			}
			return true;
				
		}
			break;
			
		case 11:
		{
			if( _session.status != XFSessionStatusOnline )
				return false;
			
			if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowFriendsOfFriendsGroup] )
			{
				[menuItem setTitle:@"Hide friends of friends"];
			}
			else 
			{
				[menuItem setTitle:@"Show friends of friends"];
			}
			return true;
		}
			break;
			
		case 12:
		{
			if( _session.status != XFSessionStatusOnline )
				return false;
			
			if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowUsernames] )
			{
				[menuItem setTitle:@"Show nicknames"];
			}
			else
			{
				[menuItem setTitle:@"Hide nicknames"];
			}
			
			return true;
		}
			break;
			
		case 13: // blackfire modes
		{
			if( _session.status == XFSessionStatusOnline )
				return true;
			else
				return false;
		}
			break;
			
		case 14: // Show 'nickname' profile
		{
			if( [_friendsListController selectedFriend] )
			{
				XFFriend * friend = [_friendsListController selectedFriend];
				[menuItem setTitle:[NSString stringWithFormat:@"Show %@'s profile",[friend displayName]]];
				return true;
			}
			[menuItem setTitle:@"Show friend's profile"];
			return false;
		}
			break;
            
        case 15:
        {
            if( [_friendsListController selectedFriend] )
            {
                return true;
            }
            else {
                return false;
            }
        }
			
		default:
		{
			return true;
		}
			break;
	}
	return false;
}

- (IBAction)help:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.macxfire.com/"]];
}



- (IBAction)toggleShowOfflineClanFriends:(id)sender
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowOfflineClanFriends] )
	{
		[[NSUserDefaults standardUserDefaults] setBool:false forKey:BFShowOfflineClanFriends];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool:true forKey:BFShowOfflineClanFriends];
	}

	[_friendsListController reloadData];
}

- (IBAction)toggleShowOfflineFriends:(id)sender
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowOfflineFriendsGroup] )
	{
		[[NSUserDefaults standardUserDefaults] setBool:false forKey:BFShowOfflineFriendsGroup];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool:true forKey:BFShowOfflineFriendsGroup];
	}
	[_session updateUserSettings];
	[_friendsListController reloadData];
}

- (IBAction)toggleShowFriendsOfFriends:(id)sender
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowFriendsOfFriendsGroup] )
	{
		[[NSUserDefaults standardUserDefaults] setBool:false forKey:BFShowFriendsOfFriendsGroup];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool:true forKey:BFShowFriendsOfFriendsGroup];
	}
	
	[_session updateUserSettings];
	[_friendsListController reloadData];
}


- (IBAction)toggleShowNicknames:(id)sender
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowUsernames] )
	{
		[[NSUserDefaults standardUserDefaults] setBool:false forKey:BFShowUsernames];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool:true forKey:BFShowUsernames];
	}
	
	[_session updateUserSettings];
	[_friendsListController reloadData];
}


- (IBAction)toggleShowClans:(id)sender
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowClanGroups] )
	{
		[[NSUserDefaults standardUserDefaults] setBool:false forKey:BFShowClanGroups];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool:true forKey:BFShowClanGroups];
	}
	
	[_friendsListController reloadData];
}

@end
