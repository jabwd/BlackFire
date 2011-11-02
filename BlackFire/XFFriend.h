//
//  XFFriend.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//
//  Stores an XFFriend representation


#import <Foundation/Foundation.h>

@class XFSession;

@interface XFFriend : NSObject
{
	XFSession *_session;
	
	NSString	*_username;
	NSString	*_nickname;
	NSString	*_firstName;
	NSString	*_lastName;
	NSString	*_statusString;
	NSData		*_sessionID;
	
	NSUInteger	_messageIndex;
	NSUInteger	_userID;
	NSUInteger	_gameID;
	NSUInteger	_gameIP;
	NSUInteger	_gamePort;
	NSUInteger	_teamspeakIP;
	NSUInteger	_teamspeakPort;
	NSUInteger	_publicIP;
	NSUInteger	_publicPort;
	NSUInteger	_natType;
	
	BOOL _online;
	BOOL _friendOfFriend;
	BOOL _clanFriend;
}

@property (nonatomic, assign) XFSession *session;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSData *sessionID;

@property (nonatomic, assign) NSUInteger messageIndex;
@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, assign) NSUInteger gameID;
@property (nonatomic, assign) NSUInteger gamePort;
@property (nonatomic, assign) NSUInteger gameIP;
@property (nonatomic, assign) NSUInteger teamspeakIP;
@property (nonatomic, assign) NSUInteger teamspeakPort;

@property (nonatomic, assign) BOOL online;
@property (nonatomic, assign) BOOL friendOfFriend;
@property (nonatomic, assign) BOOL clanFriend;

- (id)initWithSession:(XFSession *)session;
- (id)initWithUserID:(NSUInteger)userID;

//------------------------------------------------------------------------------------
// Handy methods

- (NSString *)displayName;

@end
