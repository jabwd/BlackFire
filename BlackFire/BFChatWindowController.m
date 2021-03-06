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
#import "NSNonRetardedImageView.h"
#import "XNBorderedScrollView.h"
#import "SFTabView.h"

@implementation BFChatWindowController
{	
	NSToolbarItem *_toolbarItem;
	NSMutableArray	*_chats;
}


- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChatWindow" owner:self];
		//[_window setAlphaValue:0.0f];
		[_messageView setMessageDelegate:self];
		_chats = [[NSMutableArray alloc] init];
		_currentChat = nil;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
		/*
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.125f];
		[[_window animator] setAlphaValue:1.0f];
		[NSAnimationContext endGrouping];*/
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_chats = nil;
	_toolbarItem = nil;
	[_tabStripView setDelegate:nil];
}

- (BOOL)windowShouldClose:(id)sender
{
	for(BFChat *chat in _chats)
	{
		[chat closeChat];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_chats = nil;
	
	/*NSArray *windows = [[NSApplication sharedApplication] windows];
	for(NSWindow *window in windows)
	{
		if( window == _window )
		{
			continue;
		}
		else
		{
			[window makeKeyAndOrderFront:nil];
			break;
		}
	}
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:.125f];
	if( [[NSAnimationContext currentContext] respondsToSelector:@selector(setCompletionHandler:)] )
	{
		[[NSAnimationContext currentContext] performSelector:@selector(setCompletionHandler:) withObject:^{
			[_window performClose:sender];
		}];
	}
	else {
		//[self performSelector:@selector(destroy) withObject:nil afterDelay:0.125f];
	}
	[[_window animator] setAlphaValue:0.0f];
	[NSAnimationContext endGrouping];
	return false;*/
	return true;
}

- (void)didBecomeMain:(NSNotification *)notification
{
	[_messageView becomeKey];
	[_currentChat becameMainChat];
}

- (void)awakeFromNib
{
	[_window setContentBorderThickness:35.0 forEdge:NSMinYEdge];
	[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
	[_tabStripView setDelegate:self];
	
	NSToolbar*toolbar = [[NSToolbar alloc] initWithIdentifier:@"chatWindowToolbar"];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setAutosavesConfiguration: YES];
	[toolbar setSizeMode:               NSToolbarSizeModeSmall];
	[toolbar setShowsBaselineSeparator:false];
	[toolbar setDisplayMode:            NSToolbarDisplayModeIconOnly];
	
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"smallChatToolbar" options:NSKeyValueObservingOptionNew	context:nil];
	
	_toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"status"];
	[_toolbarItem setView:_toolbarView];
	[_toolbarItem setMinSize:NSMakeSize(168.0, NSHeight([_toolbarView frame])-5)];
	[_toolbarItem setMaxSize:NSMakeSize(1920.0, NSHeight([_toolbarView frame])-5)];
	[toolbar setDelegate:self];
	[_window	setToolbar:toolbar];
	
	[_window makeKeyAndOrderFront:self];
	/*[_avatarImageView retain];
	[_avatarImageView removeFromSuperview];
	NSRect frame = [_window frame];
	[_avatarImageView setFrame:NSMakeRect(frame.size.width-32-6, frame.size.height-32-6, 32, 32)];
	[[[_window contentView] superview] addSubview:_avatarImageView];
	[_avatarImageView release];
	
	[_statusField retain];
	[_statusField removeFromSuperview];
	[_statusField setFrame:NSMakeRect(70, frame.size.height-29, frame.size.width-110, 17)];
	[_statusField setAlignment:NSRightTextAlignment];
	[[[_window contentView] superview] addSubview:_statusField];
	[_statusField release];*/
}

/*- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"Pref changed!");
}*/

#pragma mark - Managing chats

- (void)selectChat:(BFChat *)chat
{
	// don't waste time, we like it if stuff works fast :D
	if( chat == _currentChat )
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
	
	_currentChat = chat;
	[self changeSwitchView:(NSView *)chat.webView];
	[self updateToolbar];
}

- (void)didSelectNewTab:(SFTabView *)tabView
{
	for(BFChat *chat in _chats)
	{
		if( chat.chat.remoteFriend.userID == tabView.tag )
		{
			_currentChat = chat;
			[self changeSwitchView:(NSView *)chat.webView];
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
	
	if( ! _currentChat )
	{
		_currentChat = chat;
		[self changeSwitchView:(NSView *)chat.webView];
		tabView.selected = true;
	}
	[tabView setTarget:self];
	[tabView setSelector:@selector(tabShouldClose:)];
	[_tabStripView addTabView:tabView];
	[self updateToolbar];
	[chat updateTabIcon];
}

- (void)closeChat:(BFChat *)chat
{
	// this is slightly inefficient, but easier on the eyes.
	NSArray *tabViews = [_tabStripView tabs];
	for(SFTabView *tabView in tabViews)
	{
		if( [tabView tag] == chat.chat.remoteFriend.userID )
		{
			[self tabShouldClose:tabView];
			return;
		}
	}
}

- (void)tabShouldClose:(SFTabView *)tabView
{
	NSUInteger userID = tabView.tag;
	if( userID < 1 )
		return;
	
	if( [_chats count] == 1 )
	{
		[_window performClose:self];
		return;
	}
	
	NSUInteger i, cnt = [_chats count];
	for(i=0;i<cnt;i++)
	{
		BFChat *chat = _chats[i];
		if( chat.chat.remoteFriend.userID == userID )
		{
			[chat closeChat];
			[_chats removeObjectAtIndex:i];
			[_tabStripView removeTabView:tabView];
			if( chat == _currentChat )
			{
				_currentChat = nil;
				if( [_chats count] > 0 )
				{
					_currentChat = _chats[0];
				}
			}
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
		[subViews[i] removeFromSuperview];
	}
	
	[_switchView addSubview:newView];
	[newView setFrame:[_switchView bounds]];
	
	[_messageView becomeKey];
	[_currentChat becameMainChat];
}

- (SFTabView *)tabViewForChat:(BFChat *)chat
{
	if( chat )
	{
		for(SFTabView *tab in [_tabStripView tabs])
		{
			if( tab.tag == chat.chat.remoteFriend.userID )
			{
				return tab;
			}
		}
	}
	return nil;
}


#pragma mark - User interface controls

- (void)controlTextDidChange:(NSNotification *)obj
{
	[_currentChat textDidChange:obj];
}


- (void)selectNextTab
{
	NSUInteger i, cnt = [_chats count];
	for(i=0;i<cnt;i++)
	{
		BFChat *chat = _chats[i];
		if( chat != _currentChat )
		{
			continue;
		}
		if( i == (cnt - 1) )
		{
			BFChat *nextChat = _chats[0];
			[self selectChat:nextChat];
			return;
		}
		else
		{
			BFChat *nextChat = _chats[(i+1)];
			[self selectChat:nextChat];
			return;
		}
	}
}

- (void)selectPreviousTab
{
	NSUInteger i, cnt = [_chats count];
	for(i=0;i<cnt;i++)
	{
		BFChat *chat = _chats[i];
		if( chat != _currentChat )
		{
			continue;
		}
		if( i == 0 )
		{
			BFChat *nextChat = _chats[(cnt-1)];
			[self selectChat:nextChat];
			return;
		}
		else
		{
			BFChat *nextChat = _chats[(i-1)];
			[self selectChat:nextChat];
			return;
		}
	}
}

#pragma mark - Toolbar Delegate

- (void)updateToolbar
{
	XFFriend *remoteFriend = _currentChat.chat.remoteFriend;
	if( remoteFriend )
	{
		NSImage *displayImage = nil;
		NSString *statusString = remoteFriend.status;
		if( ! statusString )
			statusString = @"";

		if( remoteFriend.gameID > 0 )
		{
			displayImage = [[BFGamesManager sharedGamesManager] imageForGame:(unsigned int)remoteFriend.gameID];
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
		else if( remoteFriend.avatar )
		{
			displayImage = remoteFriend.avatar;
		}
		else {
			displayImage = [NSImage imageNamed:@"xfire"];
		}

		NSImage *newImage = [displayImage copy];
		[newImage setScalesWhenResized:true];
		[newImage setSize:NSMakeSize(32, 32)];
		[_avatarImageView setImage:newImage];
		
		if( remoteFriend.online )
		{
			if( [statusString length] < 1 )
				statusString = @"Online";
			if( [statusString rangeOfString:@"AFK"].length > 0 )
			{
				[_statusIconView setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
			}
			else
			{
				[_statusIconView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
			}
		}
		else
		{
			if( [statusString length] < 1 )
				statusString = @"Offline";
			[_statusIconView setImage:[NSImage imageNamed:@"NSStatusNone"]];
		}
		
		[_nicknameField setStringValue:[remoteFriend displayName]];
		[_statusField setStringValue:statusString];
	}
	else
	{
		NSLog(@"*** Called - (void)updateToolbar but no remoteFriend exists. Are you sure there is a chat open at this time?");
	}
	
	if( remoteFriend.online )
	{
		_messageView.editable = true;
	}
	else
	{
		_messageView.editable = false;
	}
}

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	return _toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar {
	return @[@"status"];
}


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar {
	return @[@"status"];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem 
{
	return YES;
}

#pragma mark - Message view

- (void)controlTextChanged
{
	[_currentChat textDidChange:nil];
}

- (void)sendMessage:(NSString *)message
{
	[_currentChat sendMessage:message];
}

- (void)resizeMessageView:(id)messageView{
	NSSize size = [(XNResizingMessageView *)messageView desiredSize];
	NSRect frame = [_messageScrollView frame];
	CGFloat heightAddition = size.height - frame.size.height;
	frame.size.height += heightAddition;
	[_messageScrollView setFrame:frame];
	
	// change the window frame
	NSRect windowFrame = [_window frame];
	windowFrame.size.height += heightAddition;
	windowFrame.origin.y -= heightAddition;
	CGFloat height = [_window contentBorderThicknessForEdge:NSMinYEdge];
	height += heightAddition;
	[_window setContentBorderThickness:height forEdge:NSMinYEdge];
	NSRect mainView = [_switchView frame];
	mainView.origin.y += heightAddition;
	mainView.size.height -= heightAddition;
	if( heightAddition < 0 )
	{
		[_switchView setFrame:mainView];
		[_currentChat scrollAnimated:false];
	}
	else
		[_switchView setFrame:mainView];
	/*NSRect bottom = [_backgroundView frame];
	bottom.size.height += heightAddition;
	[_backgroundView setFrame:bottom];*/
	[_window setFrame:windowFrame display:true animate:false];
}

@end
