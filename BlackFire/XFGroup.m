//
//  XFGroup.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFGroup.h"
#import "XFFriend.h"

@implementation XFGroup

@synthesize name		= _groupName;

@synthesize groupType	= _type;
@synthesize groupID		= _groupID;

- (id)init
{
	if( (self = [super init]) )
	{
		_members = [[NSMutableArray alloc] init];
		_groupName = nil;;
	}
	return self;
}

- (void)dealloc
{
	[_members release];
	_members = nil;
	[_groupName release];
	_groupName = nil;
	[super dealloc];
}

- (void)addMember:(XFFriend *)member
{
	BOOL found = false;
	for(XFFriend *friend in _members)
	{
		if( friend.userID == member.userID )
			found = true;
	}
	
	if( ! found )
	{
		[_members addObject:member];
	}
}

- (void)removeMember:(XFFriend *)member
{
	NSUInteger i, cnt = [_members count];
	for(i=0;i<cnt;i++)
	{
		if( member.userID == [_members[i] userID] )
		{
			[_members removeObjectAtIndex:i];
			return;
		}
	}
}

- (BOOL)friendIsMember:(XFFriend *)possibleMember
{
	for(XFFriend *member in _members)
	{
		if( member.userID == possibleMember.userID )
			return true;
	}
	return false;
}

- (NSUInteger)membersCount
{
	return [_members count];
}

- (XFFriend *)memberAtIndex:(NSUInteger)index
{
	return _members[index];
}


- (NSUInteger)onlineMembersCount
{
	NSUInteger count = 0;
	for(XFFriend *friend in _members)
	{
		if( friend.online )
			count++;
	}
	return count;
}

- (XFFriend *)onlineMemberAtIndex:(NSUInteger)index
{
	// this most likely works. Might be glitchy if the order of the array is changed
	// during the reloadData..
	for(XFFriend *friend in _members)
	{
		if( friend.online )
		{
			if( index == 0 )
				return friend;
			else
				index--; // loop till the index is on 0
		}
	}
	return nil;
}

- (void)sortMembers
{
	[_members sortUsingSelector:@selector(compare:)];
}

@end
