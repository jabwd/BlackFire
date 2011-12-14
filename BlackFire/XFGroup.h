//
//  XFGroup.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//
//	Stores a representation of an Xfire group

#import <Foundation/Foundation.h>

@class XFFriend;

typedef enum
{
	XFGroupTypeOnlineFriends	= 0,
	XFGroupTypeOfflineFriends	= 1,
	XFGroupTypeFriendOfFriends	= 2,
	XFGroupTypeClanGroup		= 3,
	XFGroupTypeCustom			= 4
} XFGroupType;

@interface XFGroup : NSObject
{
	NSString		*_groupName;
	NSMutableArray	*_members;
	
	XFGroupType _type;
	unsigned int _groupID;
	
}
@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) XFGroupType groupType;
@property (nonatomic, assign) unsigned int groupID;

- (void)addMember:(XFFriend *)member;
- (void)removeMember:(XFFriend *)member;

- (NSUInteger)membersCount;
- (XFFriend *)memberAtIndex:(NSUInteger)index;

- (NSUInteger)onlineMembersCount;
- (XFFriend *)onlineMemberAtIndex:(NSUInteger)index;

- (BOOL)friendIsMember:(XFFriend *)possibleMember;

- (void)sortMembers;

@end
