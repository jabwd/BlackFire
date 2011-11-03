//
//  XFSession.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFSession.h"
#import "XFConnection.h"
#import "XFFriend.h"
#import "XFGroup.h"

NSString *XFFriendDidChangeNotification		= @"XFFriendDidChangeNotification";
NSString *XFFriendChangeAttribute			= @"XFFriendChangeAttribute";

@implementation XFSession

@synthesize tcpConnection	= _tcpConnection;
@synthesize loginIdentity	= _loginIdentity;
@synthesize delegate		= _delegate;

@synthesize status = _status;

- (id)initWithDelegate:(id<XFSessionDelegate>)delegate
{
	if( (self = [super init]) )
	{
		_delegate		= delegate;
		_tcpConnection	= nil;
		_loginIdentity	= nil;
		
		_onlineFriends		= nil;
		_offlineFriends		= nil;
		_clanFriends		= nil;
		_friendOfFriends	= nil;
	}
	return self;
}

- (void)dealloc
{
	[_tcpConnection release];
	_tcpConnection = nil;
	[_loginIdentity release];
	_loginIdentity = nil;
	_status = XFSessionStatusOffline;
	[super dealloc];
}

- (void)connect
{
	if( _status != XFSessionStatusOffline )
	{
		NSLog(@"*** Tried to connect a session that is already connected or connecting");
		return;
	}
	
	[_onlineFriends release];
	_onlineFriends = [[NSMutableArray alloc] init];
	[_offlineFriends release];
	_offlineFriends = [[NSMutableArray alloc] init];
	[_friendOfFriends release];
	_friendOfFriends = [[NSMutableArray alloc] init];
	
	[_tcpConnection release];
	_tcpConnection = [[XFConnection alloc] initWithSession:self];
	[_tcpConnection connect];
}

- (void)disconnect
{
	[_tcpConnection disconnect];
	[_tcpConnection release];
	_tcpConnection = nil;
	
	[_onlineFriends release];
	_onlineFriends = nil;
	[_offlineFriends release];
	_offlineFriends = nil;
	[_clanFriends release];
	_clanFriends = nil;
	[_friendOfFriends release];
	_friendOfFriends = nil;
	
	[self setStatus:XFSessionStatusOffline];
}

- (void)setStatus:(XFSessionStatus)newStatus
{
	_status = newStatus;
	
	if( [_delegate respondsToSelector:@selector(session:statusChanged:)] )
	{
		[_delegate session:self statusChanged:_status];
	}
}

#pragma mark - Handling connection messages

- (void)loginFailed:(XFLoginError)reason
{
	if( [_delegate respondsToSelector:@selector(session:loginFailed:)] )
	{
		[_delegate session:self loginFailed:reason];
	}
	[self setStatus:XFSessionStatusOffline];
}

- (void)connection:(XFConnection *)connection willDisconnect:(XFConnectionError)connectionError
{
	[self disconnect];
}

#pragma mark - Managing friends

- (XFFriend *)onlineFriendForUsername:(NSString *)username
{
	for(XFFriend *fr in _onlineFriends)
	{
		if( [fr.username isEqualToString:username] )
			return fr;
	}
	return nil;
}

- (XFFriend *)offlineFriendForUsername:(NSString *)username
{
	for(XFFriend *fr in _offlineFriends)
	{
		if( [fr.username isEqualToString:username] )
			return fr;
	}
	return nil;
}

- (XFFriend *)clanFriendForUsername:(NSString *)username
{
	for(XFFriend *fr in _clanFriends)
	{
		if( [fr.username isEqualToString:username] )
			return fr;
	}
	return nil;
}

- (XFFriend *)friendOfFriendForUsername:(NSString *)username
{
	for(XFFriend *fr in _friendOfFriends)
	{
		if( [fr.username isEqualToString:username] )
			return fr;
	}
	return nil;
}

- (void)addFriend:(XFFriend *)newFriend
{
	if( newFriend.clanFriend )
	{
		[_clanFriends addObject:newFriend];
	}
	else if( newFriend.friendOfFriend )
	{
		[_friendOfFriends addObject:newFriend];
	}
	else if( newFriend.online )
	{
		[_onlineFriends addObject:newFriend];
	}
	else
	{
		[_offlineFriends addObject:newFriend];
	}
}

- (void)removeFriend:(XFFriend *)oldFriend
{
	NSMutableArray *friends = nil;
	if( oldFriend.clanFriend )
	{
		friends = _clanFriends;
	}
	else if( oldFriend.friendOfFriend )
	{
		friends = _friendOfFriends;
	}
	else if( oldFriend.online )
	{
		friends = _onlineFriends;
	}
	else
	{
		friends = _offlineFriends;
	}
	
	NSUInteger i, cnt = [friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[friends objectAtIndex:i] userID] == oldFriend.userID )
		{
			[friends removeObjectAtIndex:i];
			return;
		}
	}
}

@end
