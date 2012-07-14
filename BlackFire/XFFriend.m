//
//  XFFriend.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFFriend.h"
#import "XfireKit.h"
#import "BFDefaults.h"
#import "ADBitList.h"

#import "XFSession.h"

@implementation XFFriend





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
		_status	= nil;
		_sessionID		= nil;
		_receivedMessages = nil;
		
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
		_status			= nil;
		_receivedMessages = nil;
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
		_receivedMessages = nil;
		_nickname		= nil;
		_firstName		= nil;
		_lastName		= nil;
		_status	= nil;
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


#pragma mark - Handy methods

- (void)setOnlineStatus:(BOOL)online
{
	_online = online;
	if( ! _online )
	{
		_receivedMessages = nil;
		
		// the real client does not reset the message index here either.
	}
}

- (NSComparisonResult)compare:(XFFriend *)other
{
	return [[self displayName] caseInsensitiveCompare:[other displayName]];
}

- (BOOL)isAFK
{
	if( [_status length] > 0 && [_status rangeOfString:@"AFK"].length > 2 )
	{
		return true;
	}
	return false;
}

- (NSComparisonResult)statusCompare:(XFFriend *)other
{
	if( ![self  isAFK] && ![other isAFK] )
	{
		return [self compare:other];
	}
	else if( [self isAFK] && ![other isAFK] )
	{
		return NSOrderedDescending;
	}
	else if( ![self isAFK] && [other isAFK] )
	{
		return NSOrderedAscending;
	}
	else
		return [self compare:other];
}

- (NSString *)displayName
{
	if( [[NSUserDefaults standardUserDefaults] boolForKey:BFShowUsernames] )
		return _username;
	
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
	_status = nil;
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
