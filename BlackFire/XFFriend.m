//
//  XFFriend.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFFriend.h"
#import "XfireKit.h"

#import "XFSession.h"

@implementation XFFriend

@synthesize session		= _session;

@synthesize username	= _username;
@synthesize nickname	= _nickname;
@synthesize firstName	= _firstName;
@synthesize lastName	= _lastname;
@synthesize status		= _statusString;
@synthesize sessionID	= _sessionID;
@synthesize avatar		= _avatar;

@synthesize userID			= _userID;
@synthesize messageIndex	= _messageIndex;
@synthesize gameID			= _gameID;
@synthesize gameIP			= _gameIP;
@synthesize gamePort		= _gamePort;
@synthesize teamspeakIP		= _teamspeakIP;
@synthesize teamspeakPort	= _teamspeakPort;

@synthesize online			= _online;
@synthesize friendOfFriend	= _friendOfFriend;
@synthesize clanFriend		= _clanFriend;

- (id)initWithSession:(XFSession *)session
{
	if( (self = [super init]) )
	{
		_avatar			= nil;
		_session		= session;
		_username		= nil;
		_nickname		= nil;
		_firstName		= nil;
		_lastName		= nil;
		_statusString	= nil;
		_sessionID		= nil;
		
		_userID			= 0;
		_messageIndex	= 0;
		_gameID			= 0;
		_gameIP			= 0;
		_gamePort		= 0;
		_teamspeakIP	= 0;
		_teamspeakPort	= 0;
		
		
		_online			= false;
		_friendOfFriend = false;
		_clanFriend		= false;
	}
	return self;
}

- (id)initWithUserID:(NSUInteger)userID
{
	if( (self = [super init]) )
	{
		_avatar			= nil;
		_session		= nil;
		_username		= nil;
		_nickname		= nil;
		_firstName		= nil;
		_lastName		= nil;
		_statusString	= nil;
		_sessionID		= nil;
		
		_userID			= userID;
		_messageIndex	= 1;
		_gameID			= 0;
		_gameIP			= 0;
		_gamePort		= 0;
		_teamspeakIP	= 0;
		_teamspeakPort	= 0;
		
		
		_online			= false;
		_friendOfFriend = false;
		_clanFriend		= false;
	}
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_avatar			= nil;
		_session		= nil;
		_username		= nil;
		_nickname		= nil;
		_firstName		= nil;
		_lastName		= nil;
		_statusString	= nil;
		_sessionID		= nil;
		
		_userID			= 0;
		_messageIndex	= 1;
		_gameID			= 0;
		_gameIP			= 0;
		_gamePort		= 0;
		_teamspeakIP	= 0;
		_teamspeakPort	= 0;
		
		
		_online			= false;
		_friendOfFriend = false;
		_clanFriend		= false;
	}
	return self;
}

- (void)dealloc
{
	[_avatar release];
	_avatar = nil;
	[_username release];
	_username = nil;
	[_nickname release];
	_nickname = nil;
	[_firstName release];
	_firstName = nil;
	[_lastName release];
	_lastName = nil;
	[_statusString release];
	_statusString = nil;
	[_sessionID release];
	_sessionID = nil;
	[super dealloc];
}

#pragma mark - Handy methods

- (NSComparisonResult)compare:(XFFriend *)other
{
	return [[self displayName] caseInsensitiveCompare:[other displayName]];
}

- (NSString *)displayName
{
	if( [_nickname length] > 0 )
		return _nickname;
	
	return _username;
}

- (NSString *)gameIPString
{
	if( _gameIP == 0 )
		return @"";
	return [NSString stringWithFormat:@"%@:%lu",NSStringFromIPAddress(_gameIP),_gamePort];
}

- (void)clearInformation
{
	_gameIP = 0;
	_gamePort = 0;
	[_statusString release];
	_statusString = nil;
	_teamspeakIP = 0;
	_teamspeakPort = 0;
	_messageIndex = 0;
	_gameID = 0;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[%@ userID=%lu]",_username,_userID];
}

@end
