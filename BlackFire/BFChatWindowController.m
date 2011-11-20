//
//  BFChatWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChatWindowController.h"
#import "BFChat.h"

#import "SFTabStripView.h"
#import "SFTabView.h"

@implementation BFChatWindowController

@synthesize switchView = _switchView;
@synthesize window = _window;
@synthesize messageField = _messageField;

@synthesize tabStripView = _tabStripView;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChatWindow" owner:self];
		[_window setContentBorderThickness:34.0 forEdge:NSMinYEdge];
		[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
		[_window makeKeyAndOrderFront:self];
		[_window setTitle:@""];
		
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

- (void)addChat:(BFChat *)chat
{
	[_chats addObject:chat];
	
	chat.windowController = self;
	
	SFTabView *tabView = [[SFTabView alloc] init];
	tabView.title = [chat.chat.remoteFriend displayName];
	
	if( ! _currentlySelectedChat )
	{
		_currentlySelectedChat = chat;
		[self changeSwitchView:chat.chatScrollView];
		tabView.selected = true;
	}
	[_tabStripView addTabView:tabView];
	[tabView release];
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
}


#pragma mark - User interface controls

- (IBAction)sendMessage:(id)sender
{
	[_currentlySelectedChat sendMessage:[_messageField stringValue]];
	
	[_messageField setStringValue:@""];
	[_messageField setNeedsDisplay:true];
}

@end
