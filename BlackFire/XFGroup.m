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
		
	}
	return self;
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
		if( member.userID == [[_members objectAtIndex:i] userID] )
		{
			[_members removeObjectAtIndex:i];
			return;
		}
	}
}

- (NSUInteger)membersCount
{
	return [_members count];
}

- (XFFriend *)memberAtIndex:(NSUInteger)index
{
	return [_members objectAtIndex:index];
}

@end
