//
//  XFGroupController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFGroupController.h"
#import "XFGroup.h"

@implementation XFGroupController

@synthesize session = _session;

- (id)init
{
	if( (self = [super init]) )
	{
		_groups = [[NSMutableArray alloc] init];
		
		// create the standard groups ( whether we need them or not )
		XFGroup *onlineFriendsGroup		= [[XFGroup alloc] init];
		XFGroup *offlineFriendsGroup	= [[XFGroup alloc] init];
		XFGroup *friendsOfFriendsGroup	= [[XFGroup alloc] init];
		
		onlineFriendsGroup.groupID		= 1;
		offlineFriendsGroup.groupID		= 2;
		friendsOfFriendsGroup.groupID	= 3;
		
		onlineFriendsGroup.name		= @"Online";
		offlineFriendsGroup.name	= @"Offline";
		friendsOfFriendsGroup.name	= @"Friends of friends";
		
		onlineFriendsGroup.groupType	= XFGroupTypeOnlineFriends;
		offlineFriendsGroup.groupType	= XFGroupTypeOfflineFriends;
		friendsOfFriendsGroup.groupType = XFGroupTypeFriendOfFriends;
		
		[_groups addObject:onlineFriendsGroup];
		[_groups addObject:offlineFriendsGroup];
		[_groups addObject:friendsOfFriendsGroup];
		
		[onlineFriendsGroup		release];
		[offlineFriendsGroup	release];
		[friendsOfFriendsGroup	release];
	}
	return self;
}

- (void)dealloc
{
	[_groups release];
	_groups = nil;
	[super dealloc];
}

#pragma mark - Managing groups

- (void)addGroup:(XFGroup *)newGroup
{
	BOOL found = false;
	for(XFGroup *group in _groups)
	{
		if( group.groupID == newGroup.groupID )
			found = true;
	}
	
	if( ! found )
	{
		[_groups addObject:newGroup];
	}
}

- (void)removeGroup:(XFGroup *)oldGroup
{
	NSUInteger i, cnt = [_groups count];
	for(i=0;i<cnt;i++)
	{
		if( [[_groups objectAtIndex:i] groupID] == oldGroup.groupID )
		{
			[_groups removeObjectAtIndex:i];
			return;
		}
	}
}

- (XFGroup *)onlineFriendsGroup
{
	return [self groupForID:1];
}

- (XFGroup *)offlineFriendsGroup
{
	return [self groupForID:2];
}

- (XFGroup *)friendsOfFriendsGroup
{
	return [self groupForID:3];
}

- (XFGroup *)groupForID:(unsigned int)groupID
{
	for(XFGroup *group in _groups)
	{
		if( group.groupID == groupID )
			return group;
	}
	return nil;
}


- (void)addCustomGroup:(NSString *)name groupID:(unsigned int)groupID
{
	XFGroup *group	= [[XFGroup alloc] init];
	group.name		= name;
	group.groupType = XFGroupTypeCustom;
	group.groupID	= groupID;
	
	[_groups addObject:group];
	[group release];
}

- (void)addClanGroup:(NSString *)clanName groupID:(unsigned int)groupID
{
	XFGroup *group	= [[XFGroup alloc] init];
	group.name		= clanName;
	group.groupType = XFGroupTypeClanGroup;
	group.groupID	= groupID;
	
	[_groups addObject:group];
	[group release];
}

#pragma mark - Managing group members

- (void)addMember:(XFFriend *)fr toGroup:(XFGroup *)group
{
	[group addMember:fr];
}

- (void)removeMember:(XFFriend *)fr fromGroup:(XFGroup *)group
{
	[group removeMember:fr];
}

@end
