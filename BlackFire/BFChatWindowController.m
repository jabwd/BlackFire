//
//  BFChatWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChatWindowController.h"
#import "BFChat.h"

@implementation BFChatWindowController

@synthesize messageTableView = _messageTableView;

@synthesize window = _window;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChatWindow" owner:self];
		[_window setContentBorderThickness:34.0 forEdge:NSMinYEdge];
		[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
		[_window makeKeyAndOrderFront:self];
		
		_chats = [[NSMutableArray alloc] init];
		_currentlySelectedChat = nil;
	}
	return self;
}

- (void)dealloc
{
	[_chats release];
	_chats = nil;
	[super dealloc];
}

#pragma mark - Managing chats

- (void)addChat:(BFChat *)chat
{
	[_chats addObject:chat];
	
	if( ! _currentlySelectedChat )
	{
		_currentlySelectedChat = chat;
	}
}

- (void)reloadData
{
	[_messageTableView reloadData];
}

#pragma mark - NSTableViewDatasource and delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return 0;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 20.0f;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	
}

#pragma mark - NSSplitviewDelegate
/*
-(NSView* )resizeView 
{
	// TODO: return the view which contains the resize control
}

-(NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
	return [[self resizeView] convertRect:[[self resizeView] bounds] toView:splitView]; 
}*/

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 65.0f;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 10000.0f;
}

@end
