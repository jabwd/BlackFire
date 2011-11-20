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
#import "BFSetupWindowController.h"

#import "BFLoginViewController.h"
#import "BFFriendsListController.h"

#import "BFChatWindowController.h"
#import "BFChat.h"

@implementation ADAppDelegate

@synthesize window			= _window;
@synthesize session			= _session;
@synthesize mainView		= _mainView;
@synthesize toolbarView		= _toolbarView;

- (void)dealloc
{
	[_setupWindowController release];
	_setupWindowController = nil;
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
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"finishedSetup"] )
	{
		_setupWindowController = [[BFSetupWindowController alloc] initWithWindowNibName:@"BFSetupWindow"];
		_setupWindowController.delegate = self;
	}
	else
	{
		NSArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
		if( [accounts count] > 0 )
		{
			[_account release];
			_account = [[BFAccount alloc] initWithUsername:[accounts objectAtIndex:0]];
			[self connectionCheck];
		}
		else
		{
			_setupWindowController = [[BFSetupWindowController alloc] initWithWindowNibName:@"BFSetupWindow"];
			_setupWindowController.delegate = self;
		}
	}
}

#pragma mark - Setup window

- (void)setupWindowClosed
{
	[_setupWindowController release];
	_setupWindowController = nil;
	
	[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"finishedSetup"];
	
	NSArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
	if( [accounts count] > 0 )
	{
		[_account release];
		_account = [[BFAccount alloc] initWithUsername:[accounts objectAtIndex:0]];
	}
	
	[self connectionCheck];
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
			if( ! _loginViewController )
			{
				_loginViewController = [[BFLoginViewController alloc] init];
			}
			[_loginViewController session:_session changedStatus:XFSessionStatusOffline];
			
			[self changeMainView:_loginViewController.view];
		}
			break;
			
		case BFApplicationModeLoggingIn:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusConnecting];
		}
			break;
			
		case BFApplicationModeOnline:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusOnline];
			
			if( ! _friendsListController )
				_friendsListController = [[BFFriendsListController alloc] initWithSession:_session];
			
			[self changeMainView:_friendsListController.view];
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
		chatController = [[BFChatWindowController alloc] init];
	
	BFChat *blackfireChat = [[BFChat alloc] initWithChat:chat];
	[chatController addChat:blackfireChat];
	[chat setDelegate:blackfireChat];
	
	[_chatControllers addObject:blackfireChat];
	[blackfireChat release];
}

- (void)connectionCheck
{
	if( !_session || _session.status == XFSessionStatusOffline )
	{
		_session = [[XFSession alloc] initWithDelegate:self];
		[_session connect];
	}
}

- (void)session:(XFSession *)session loginFailed:(XFLoginError)reason
{
	
}

- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus
{
	if( newStatus == XFSessionStatusOnline )
	{
		[self changeToMode:BFApplicationModeOnline];
	}
	else if( newStatus == XFSessionStatusConnecting )
	{
		[self changeToMode:BFApplicationModeLoggingIn];
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		[self changeToMode:BFApplicationModeOffline];
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



- (NSString *)username
{
	return _account.username;
}

- (NSString *)password
{
	return _account.password;
}

@end
