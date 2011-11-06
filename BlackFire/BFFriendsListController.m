//
//  BFFriendsListController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFFriendsListController.h"
#import "BFImageAndTextCell.h"

#import "XFSession.h"
#import "XFGroupController.h"
#import "XFGroup.h"
#import "XFFriend.h"

@implementation BFFriendsListController

@synthesize friendsList = _friendsList;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"FriendsList" owner:self];
		[_friendsList setDoubleAction:@selector(doubleClick)];
	}
	return self;
}

- (id)initWithSession:(XFSession *)session
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"FriendsList" owner:self];
		[_friendsList setDoubleAction:@selector(doubleClick)];
		NSTableColumn *column = [[_friendsList tableColumns] objectAtIndex:0];
		BFImageAndTextCell *cell = [column dataCell];
		[cell setEditable:NO];
		[cell setDisplayImageSize:NSMakeSize(23.0f, 23.0f)];
		
		_session = session;
	}
	return self;
}

- (void)dealloc
{
	_session = nil;
	[super dealloc];
}

- (void)reloadData
{
	[_friendsList reloadData];
}

#pragma mark - Outlineview datasource

- (NSUInteger)selectedRow
{
	NSUInteger selectedRow = [_friendsList selectedRow];
	if( [_friendsList clickedRow] != selectedRow )
	{
		return [_friendsList clickedRow];
	}
	return selectedRow;
}

- (void)doubleClicked
{
	
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if( item == nil )
	{
		return [_session.groupController.groups count];
	}
	else if( [item isKindOfClass:[XFGroup class]] )
	{
		return [(XFGroup *)item membersCount];
	}
	return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if( item == nil || [item isKindOfClass:[XFGroup class]] )
		return true;
	return false;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if( item == nil )
	{
		return [_session.groupController.groups objectAtIndex:index];
	}
	else if( [item isKindOfClass:[XFGroup class]] )
	{
		return [(XFGroup *)item memberAtIndex:index];
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
	return true;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
	return true;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
	{
		return [(XFGroup *)item name];
	}
	else if( [item isKindOfClass:[XFFriend class]] )
	{
		return [(XFFriend *)item displayName];
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if( [item isKindOfClass:[XFFriend class]] )
	{
		XFFriend			*friend			= (XFFriend *)item;
		BFImageAndTextCell	*imageCell		= (BFImageAndTextCell *)cell;
		
		[imageCell setImage:[NSImage imageNamed:@"xfire"]];
		
		NSString *status = friend.status;
		if( [status rangeOfString:@"AFK"].length > 0 )
		{
			[imageCell setFriendStatus:CellStatusAFK];
		}
		else if( friend.online )
		{
			[imageCell setFriendStatus:CellStatusOnline];
		}
		else
		{
			[imageCell setFriendStatus:CellStatusOffline];
		}
		
		if( [status length] > 0 )
		{
			[(BFImageAndTextCell *)cell setShowsStatus:true];
			if( friend.gameIP != 0 )
			{
				status = [NSString stringWithFormat:@"%@ %@",status,[friend gameIPString]];
			}
			[(BFImageAndTextCell *)cell setCellStatusString:status];
		}
		else
		{
			[(BFImageAndTextCell *)cell setShowsStatus:false];
		}
	} 
	else
	{
		[(BFImageAndTextCell *)cell setStatusImage:nil];
		[(BFImageAndTextCell *)cell setShowsStatus:NO];
		[cell setImage:nil];
	}
}

- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation
{
	return @"Tooltip";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
		return true;
	return false;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
	{
		return 18.0f;
	}
	return 26.0f;
}

@end
