//
//  BFChatWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChatWindowController.h"
#import "BFChat.h"
#import "XFChat.h"
#import "XFFriend.h"

#import "BFGamesManager.h"

#import "SFTabView.h"

@implementation BFChatWindowController

@synthesize switchView		= _switchView;
@synthesize window			= _window;
@synthesize messageField	= _messageField;
@synthesize toolbarView		= _toolbarView;

@synthesize avatarImageView = _avatarImageView;
@synthesize statusIconView	= _statusIconView;
@synthesize nicknameField	= _nicknameField;
@synthesize statusField		= _statusField;

@synthesize tabStripView	= _tabStripView;
@synthesize currentChat		= _currentlySelectedChat;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChatWindow" owner:self];
		[_window setContentBorderThickness:34.0 forEdge:NSMinYEdge];
		[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
		[_window makeKeyAndOrderFront:self];
		[_window setTitle:@""];
		[_tabStripView setDelegate:self];
		
		NSToolbar*toolbar = [[NSToolbar alloc] initWithIdentifier:@"chatWindowToolbar"];
		[toolbar setAllowsUserCustomization:NO];
		[toolbar setAutosavesConfiguration: YES];
		[toolbar setSizeMode:               NSToolbarSizeModeSmall];
		[toolbar setShowsBaselineSeparator:false];
		[toolbar setDisplayMode:            NSToolbarDisplayModeIconOnly];
		
		_toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"status"];
		[_toolbarItem setView:_toolbarView];
		[_toolbarItem setMinSize:NSMakeSize(168.0, NSHeight([_toolbarView frame]))];
		[_toolbarItem setMaxSize:NSMakeSize(1920.0, NSHeight([_toolbarView frame]))];
		
		[toolbar      setDelegate:self];
		[_window	setToolbar:toolbar];
		[toolbar      release];

		
		_chats = [[NSMutableArray alloc] init];
		_currentlySelectedChat = nil;
	}
	return self;
}

- (void)dealloc
{
	[_chats release];
	_chats = nil;
	_currentlySelectedChat = nil;
	[super dealloc];
}

- (BOOL)windowShouldClose:(id)sender
{
	for(BFChat *chat in _chats)
	{
		[chat closeChat];
	}
	[_chats release];
	_chats = [[NSMutableArray alloc] init];
	
	// get rid of this chatwindow controller
	[self release];
	self = nil;
	return true;
}

#pragma mark - Managing chats

- (void)selectChat:(BFChat *)chat
{
	// don't waste time, we like it if stuff works fast :D
	if( chat == _currentlySelectedChat )
		return;
	
	// select the correct tab
	NSArray *tabViews = [_tabStripView tabs];
	for(SFTabView *tabView in tabViews)
	{
		if( [tabView tag] == chat.chat.remoteFriend.userID )
			tabView.selected = true;
		else
			tabView.selected = false;
	}
	[_tabStripView layoutTabs];
	
	_currentlySelectedChat = chat;
	[self changeSwitchView:chat.chatScrollView];
	[self updateToolbar];
}

- (void)didSelectNewTab:(SFTabView *)tabView
{
	for(BFChat *chat in _chats)
	{
		if( chat.chat.remoteFriend.userID == tabView.tag )
		{
			_currentlySelectedChat = chat;
			[self changeSwitchView:chat.chatScrollView];
			[self updateToolbar];
			return;
		}
	}
}

- (void)addChat:(BFChat *)chat
{
	[_chats addObject:chat];
	
	chat.windowController = self;
	
	SFTabView *tabView = [[SFTabView alloc] init];
	tabView.title = [chat.chat.remoteFriend displayName];

	[tabView setTag:chat.chat.remoteFriend.userID];
	
	if( ! _currentlySelectedChat )
	{
		_currentlySelectedChat = chat;
		[self changeSwitchView:chat.chatScrollView];
		tabView.selected = true;
	}
	[tabView setTarget:self];
	[tabView setSelector:@selector(tabShouldClose:)];
	[_tabStripView addTabView:tabView];
	[tabView release];
	[self updateToolbar];
}

- (void)tabShouldClose:(SFTabView *)tabView
{
	NSUInteger userID = tabView.tag;
	if( userID < 1 )
		return;
	
	if( [_chats count] == 1 )
	{
		[[self window] performClose:self];
		return;
	}
	
	NSUInteger i, cnt = [_chats count];
	for(i=0;i<cnt;i++)
	{
		BFChat *chat = [_chats objectAtIndex:i];
		if( chat.chat.remoteFriend.userID == userID )
		{
			[chat closeChat];
			[_chats removeObjectAtIndex:i];
			[_tabStripView removeTabView:tabView];
			return;
		}
	}
}

- (void)changeSwitchView:(NSView *)newView
{
	NSArray *subViews = [_switchView subviews];
	NSUInteger i, cnt = [subViews count];
	for(i=0;i<cnt;i++)
	{
		[[subViews objectAtIndex:i] removeFromSuperview];
	}
	
	[_switchView addSubview:newView];
	[newView setFrame:[_switchView bounds]];
	
	[_messageField becomeFirstResponder];
}


#pragma mark - User interface controls

- (IBAction)sendMessage:(id)sender
{
	[_currentlySelectedChat sendMessage:[_messageField stringValue]];
	
	[_messageField setStringValue:@""];
	[_messageField setNeedsDisplay:true];
}

#pragma mark - Toolbar Delegate

- (void)updateToolbar
{
	XFFriend *remoteFriend = _currentlySelectedChat.chat.remoteFriend;
	if( remoteFriend )
	{
		NSImage *displayImage = nil;
		NSString *statusString = remoteFriend.status;
		if( ! statusString )
			statusString = @"";
#warning Finish this shit
		if( remoteFriend.gameID > 0 )
		{
			displayImage = [[BFGamesManager sharedGamesManager] imageForGame:remoteFriend.gameID];
			if( [statusString length] > 0 )
			{
				statusString = [NSString stringWithFormat:@"%@, ",statusString];
			}
			
			if( remoteFriend.gameIP > 0 )
			{
				statusString = [NSString stringWithFormat:@"%@Playing %@ on %@",statusString,[[BFGamesManager sharedGamesManager] longNameForGameID:remoteFriend.gameID],[remoteFriend gameIPString]];
			}
			else
			{
				statusString = [NSString stringWithFormat:@"%@Playing %@",statusString,[[BFGamesManager sharedGamesManager] longNameForGameID:remoteFriend.gameID]];
			}
		}
		else
			displayImage = [NSImage imageNamed:@"xfire"];

		[_avatarImageView setImage:displayImage];
		if( [statusString length] < 1 && remoteFriend.online )
			statusString = @"Online";
		else if( ! remoteFriend.online )
			statusString = @"Offline";
		[_statusField setStringValue:statusString];
		
		if( [statusString rangeOfString:@"AFK"].length > 0 )
		{
			[_statusIconView setImage:[NSImage imageNamed:@"away_bubble"]];
		}
		else
		{
			[_statusIconView setImage:[NSImage imageNamed:@"avi_bubble"]];
		}
		
		[_nicknameField setStringValue:[remoteFriend displayName]];
	}
	else
	{
		NSLog(@"*** Called - (void)updateToolbar but no remoteFriend exists. Are you sure there is a chat open at this time?");
	}
	
	if( remoteFriend.online )
	{
		[_messageField setHidden:false];
	}
	else
	{
		[_messageField setHidden:true];
	}
}

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

@end
