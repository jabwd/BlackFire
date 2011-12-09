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

#import "BFAccount.h"

#import "BFLoginViewController.h"
#import "BFFriendsListController.h"

#import "BFChatWindowController.h"
#import "BFChat.h"

#import "BFNotificationCenter.h"

@implementation ADAppDelegate

@synthesize window			= _window;
@synthesize session			= _session;
@synthesize mainView		= _mainView;
@synthesize toolbarView		= _toolbarView;

@synthesize avatarImageView			= _avatarImageView;
@synthesize statusBubbleView		= _statusBubbleView;
@synthesize nicknamePopUpButton		= _nicknamePopUpButton;
@synthesize statusPopUpButton		= _statusPopUpButton;

@synthesize currentMode = _currentMode;

- (void)dealloc
{
	[_session disconnect];
	[_session release];
	_session = nil;
	[_account release];
	_account = nil;
	[_chatControllers release];
	_chatControllers = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
	[[BFGamesManager sharedGamesManager] setDelegate:self];
	_chatControllers = [[NSMutableArray alloc] init];
	
	
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
    [toolbar      release];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	if( ![_window isVisible] )
	{
		[_window makeKeyAndOrderFront:self];
	}
	return false;
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	return nil;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self connectionCheck];
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	switch([menuItem tag])
	{
		case 2:
		{
			// previou stab
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
		}
			break;
			
		case 5:
		{
			// show profile
		}
			break;
			
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

#pragma mark - Toolbar delegate
- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	return _toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar {
	return [NSArray arrayWithObjects:@"status", nil];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar {
	return [NSArray arrayWithObjects:@"status", nil];
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
				[_stringPromptController release];
				_stringPromptController = nil;
			}
			
			if( ! _loginViewController )
			{
				_loginViewController = [[BFLoginViewController alloc] init];
				_loginViewController.delegate = self;
			}
			[_friendsListController release];
			_friendsListController = nil;
			[_loginViewController session:_session changedStatus:XFSessionStatusOffline];
			
			[_statusBubbleView setImage:nil];
			[_avatarImageView setImage:nil];
			
			//[_statusPopUpButton selectItemWithTitle:@"Offline"];
			[_statusPopUpButton setTitle:@"Offline"];
			[_nicknamePopUpButton setTitle:@""];
			[_statusPopUpButton selectItemWithTag:0];
			
			[self changeMainView:_loginViewController.view];
		}
			break;
			
		case BFApplicationModeLoggingIn:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusConnecting];
			[_statusPopUpButton setTitle:@"Connecting…"];
		}
			break;
			
		case BFApplicationModeOnline:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusOnline];
			
			if( ! _friendsListController )
			{
				_friendsListController = [[BFFriendsListController alloc] initWithSession:_session];
				_friendsListController.delegate = self;
			}
			
			[self changeMainView:_friendsListController.view];
			
			[_statusBubbleView setImage:[NSImage imageNamed:@"avi_bubble"]];
			[_avatarImageView setImage:[NSImage imageNamed:@"xfire"]];
			
			[_statusPopUpButton setTitle:@"Available"];
			NSString *nickname = [[_session loginIdentity] displayName];
			if( ! nickname )
				nickname = @":D"; // this should actually never ever happen
			[_nicknamePopUpButton setTitle:nickname];
			
		}
			break;
			
		case BFApplicationModeGames:
		{
			
		}
			break;
			
		case BFApplicationModeServers:
		{
			
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
	NSArray *subviews = [_mainView subviews];
	for(NSView *view in subviews)
	{
		[view removeFromSuperview];
	}
	
	[_mainView addSubview:newView];
	[newView setFrame:[_mainView bounds]];
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
		BFChat *bfchat = [_chatControllers objectAtIndex:i];
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
		chatController = [[_chatControllers objectAtIndex:0] windowController];
	}
	else
	{
		chatController = [[BFChatWindowController alloc] init];
	}
	
	BFChat *blackfireChat = [[BFChat alloc] initWithChat:chat];
	[chatController addChat:blackfireChat];
	[chat setDelegate:blackfireChat];
	
	[_chatControllers addObject:blackfireChat];
	[blackfireChat release];
}




- (void)connectionCheck
{
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"];
	if( [username length] < 1 )
		return;
	[_account release];
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
	[_session release];
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
	
	// make sure that the friends list displays the latest data
	[_friendsListController reloadData];
	
	if( notificationType == XFFriendNotificationOnlineStatusChanged && [[changedFriend displayName] length] > 0 )
	{
		if( changedFriend.online )
		{
			[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:@"Friend came online" body:[NSString stringWithFormat:@"%@ came online",[changedFriend displayName]]];
			[[BFNotificationCenter defaultNotificationCenter] playOnlineSound];
		}
		else
		{
			[[BFNotificationCenter defaultNotificationCenter] postNotificationWithTitle:@"Friend went offline" body:[NSString stringWithFormat:@"%@ went offline",[changedFriend displayName]]];
			[[BFNotificationCenter defaultNotificationCenter] playOfflineSound];
		}
	}
	
	// now post an application wide notification so other classes can update their shit too
	// ( mainly for the chat anyways ).
	NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:notificationType],@"type", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:XFFriendDidChangeNotification object:changedFriend userInfo:userInfo];
	[userInfo release];
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
		NSRunAlertPanel(@"Error", [NSString stringWithFormat:@"An error occured %lu",reason], @"OK", nil, nil);
	}
}



- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus
{
	if( newStatus == XFSessionStatusOnline )
	{
		[[BFGamesManager sharedGamesManager] startMonitoring];
		[self changeToMode:BFApplicationModeOnline];
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
			BFChat *chat = [_chatControllers objectAtIndex:0];
			[chat.windowController closeChat:chat];
		}
		[[BFGamesManager sharedGamesManager] stopMonitoring];
		[self changeToMode:BFApplicationModeOffline];
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		[_session setDelegate:nil];
		[_session release];
		_session = nil;
	}
}



- (void)session:(XFSession *)session didReceiveFriendShipRequests:(NSArray *)requests
{
#warning implement this method
	NSLog(@"Received friend ship request: %@",requests);
}

- (void)session:(XFSession *)session didReceiveSearchResults:(NSArray *)results
{
#warning implement this method
	NSLog(@"Received search results: %@",results);
}


- (void)session:(XFSession *)session nicknameChanged:(NSString *)newNickname
{
	[_nicknamePopUpButton setTitle:newNickname];
	[_friendsListController reloadData];
}


- (NSString *)username
{
	return _account.username;
}

- (NSString *)password
{
	return _account.password;
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

#pragma mark - Friends list toolbar

- (IBAction)selectStatus:(id)sender
{
	
}

- (IBAction)selectNicknameOption:(id)sender
{
	if( _stringPromptController )
	{
		NSLog(@"*** Cannot change nickname while another string prompt is running");
	}
	else
	{
		_stringPromptController = [[ADStringPromptController alloc] initWithWindow:_window];
		NSString *nickname = [[_session loginIdentity] nickname];
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
	NSString *nickname = [_stringPromptController.messageField.stringValue copy];
	[_stringPromptController release];
	_stringPromptController = nil;
	
	[_session setNickname:nickname];
	
	[nickname release];
}

- (void)stringPromptDidCancel:(ADStringPromptController *)prompt
{
	[_stringPromptController release];
	_stringPromptController = nil;
}

@end
