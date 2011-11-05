//
//  XFGroupController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XFGroup, XFFriend, XFSession;


@interface XFGroupController : NSObject
{
	NSMutableArray *_groups;
	
	XFSession		*_session;
}

@property (nonatomic, assign) XFSession *session;


//----------------------------------------------------------
// Managing groups

- (void)addGroup:(XFGroup *)newGroup;
- (void)removeGroup:(XFGroup *)oldGroup;

- (XFGroup *)onlineFriendsGroup;
- (XFGroup *)offlineFriendsGroup;
- (XFGroup *)friendsOfFriendsGroup;

- (XFGroup *)groupForID:(unsigned int)groupID;

- (void)addCustomGroup:(NSString *)name groupID:(unsigned int)groupID;
- (void)addClanGroup:(NSString *)clanName groupID:(unsigned int)groupID;

//----------------------------------------------------------
// Managing group members

/*
 * These methods automatically find out to what group they belong.
 */
- (void)addMember:(XFFriend *)fr toGroup:(XFGroup *)group;
- (void)removeMember:(XFFriend *)fr fromGroup:(XFGroup *)group;

@end
