//
//  BFFriendsListController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFFriendsListController.h"

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
	}
	return self;
}

- (id)initWithSession:(XFSession *)session
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"FriendsList" owner:self];
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

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
		return true;
	return false;
}

@end
