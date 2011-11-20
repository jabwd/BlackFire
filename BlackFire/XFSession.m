//
//  XFSession.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFSession.h"
#import "XFConnection.h"
#import "XFFriend.h"
#import "XFGroup.h"
#import "XFGroupController.h"
#import "XFChat.h"
#import "NSData_XfireAdditions.h"

NSString *XFFriendDidChangeNotification		= @"XFFriendDidChangeNotification";
NSString *XFFriendChangeAttribute			= @"XFFriendChangeAttribute";

@implementation XFSession

@synthesize tcpConnection	= _tcpConnection;
@synthesize loginIdentity	= _loginIdentity;
@synthesize delegate		= _delegate;
@synthesize groupController = _groupController;

@synthesize status = _status;

- (id)initWithDelegate:(id<XFSessionDelegate>)delegate
{
	if( (self = [super init]) )
	{
		_delegate			= delegate;
		_tcpConnection		= nil;
		_loginIdentity		= nil;
		_groupController	= nil;
		
		_friends			= nil;
		_chats				= nil;
		_groupChats			= nil;
	}
	return self;
}

- (void)dealloc
{
	[_keepAliveTimer invalidate];
	_keepAliveTimer = nil;
	[_tcpConnection release];
	_tcpConnection = nil;
	[_loginIdentity release];
	_loginIdentity = nil;
	[_groupController release];
	_groupController = nil;
	_status = XFSessionStatusOffline;
	_delegate = nil;
	[_friends release];
	_friends = nil;
	[_chats release];
	_chats = nil;
	[_groupChats release];
	_groupChats = nil;
	[super dealloc];
}

- (void)connect
{
	if( _status != XFSessionStatusOffline )
	{
		NSLog(@"*** Tried to connect a session that is already connected or connecting");
		return;
	}
	
	[self setStatus:XFSessionStatusConnecting];
	
	[_friends release];
	_friends = [[NSMutableArray alloc] init];
	[_groupController release];
	_groupController = [[XFGroupController alloc] init];
	
	[_loginIdentity release];
	_loginIdentity = [[XFFriend alloc] init];
	
	[_tcpConnection release];
	_tcpConnection = [[XFConnection alloc] initWithSession:self];
	[_tcpConnection connect];
	
	[_chats release];
	_chats = [[NSMutableArray alloc] init];
	
	[_groupChats release];
	_groupChats = [[NSMutableArray alloc] init];
	
	[_keepAliveTimer invalidate];
	_keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(sendKeepAlive:) userInfo:nil repeats:true];
}

- (void)disconnect
{
	[self setStatus:XFSessionStatusDisconnecting];
	
	[_keepAliveTimer invalidate];
	_keepAliveTimer = nil;
	[_tcpConnection disconnect];
	[_tcpConnection release];
	_tcpConnection = nil;
	[_groupController release];
	_groupController = nil;
	
	[_loginIdentity release];
	_loginIdentity = nil;
	
	[_friends release];
	_friends = nil;
	
	[_chats release];
	_chats = nil;
	
	[_groupChats release];
	_groupChats = nil;
	
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

- (void)sendKeepAlive:(NSTimer *)timer
{
	[_tcpConnection sendKeepAliveRequest];
}

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

- (void)raiseFriendNotification:(XFFriendNotification)notification forFriend:(XFFriend *)fr
{
	if( notification == XFFriendNotificationFriendAdded )
	{
	}
}

- (XFFriend *)friendForUserID:(unsigned int)userID
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[_friends objectAtIndex:i] userID] == userID )
			return [_friends objectAtIndex:i];
	}
	return nil;
}

- (XFFriend *)friendForUsername:(NSString *)username
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[[_friends objectAtIndex:i] username] isEqualToString:username] )
			return [_friends objectAtIndex:i];
	}
	return nil;
}

- (XFFriend *)friendForSessionID:(NSData *)sessionID
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[[_friends objectAtIndex:i] sessionID] isEqualToData:sessionID] )
			return [_friends objectAtIndex:i];
	}
	return nil;
}

- (void)addFriend:(XFFriend *)newFriend
{
	[_friends addObject:newFriend];
}

- (void)removeFriend:(XFFriend *)oldFriend
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[_friends objectAtIndex:i] userID] == oldFriend.userID )
		{
			[_friends removeObjectAtIndex:i];
			return;
		}
	}
}

- (void)friendWasDeleted:(unsigned int)userID
{
	XFFriend *friend = nil;
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[_friends objectAtIndex:i] userID] == userID )
		{
			friend = [[_friends objectAtIndex:i] retain];
			[_friends removeObjectAtIndex:i];
			break;
		}
	}
	[self raiseFriendNotification:XFFriendNotificationFriendRemoved forFriend:friend];
	[friend release];
}

#pragma mark - Managing chats

- (XFChat *)chatForSessionID:(NSData *)sessionID
{
	for(XFChat *chat in _chats)
	{
		if( [chat.remoteFriend.sessionID isEqualToData:sessionID] )
			return chat;
	}
	return nil;
}

- (XFChat *)beginNewChatForFriend:(XFFriend *)remoteFriend
{
	XFChat *chat	= [[XFChat alloc] initWithRemoteFriend:remoteFriend];
	chat.connection = _tcpConnection;
	
	if( [_delegate respondsToSelector:@selector(session:chatDidStart:)] )
		[_delegate session:self chatDidStart:chat];
	
	[_chats addObject:chat];
	
	return chat;
}

- (void)closeChat:(XFChat *)chat
{
	[chat retain];
	NSUInteger i, cnt = [_chats count];
	for(i=0;i<cnt;i++)
	{
		XFChat *chat_ = [_chats objectAtIndex:i];
		if( chat_.remoteFriend.userID == chat.remoteFriend.userID )
		{
			[_chats removeObjectAtIndex:i];
			break;
		}
	}
	
	if( [_delegate respondsToSelector:@selector(session:chatDidEnd:)] )
		[_delegate session:self chatDidEnd:chat];
	
	[chat release];
}


#pragma mark - Handling some misc connection stuff

- (void)receivedFriendShipRequests:(NSArray *)requests
{
	if( [requests count] < 1 )
		return;
	
	if( [_delegate respondsToSelector:@selector(session:didReceiveFriendShipRequests:)] )
		[_delegate session:self didReceiveFriendShipRequests:requests];
}


- (void)receivedSearchResults:(NSArray *)results
{
	if( [_delegate respondsToSelector:@selector(session:didReceiveSearchResults:)] )
		[_delegate session:self didReceiveSearchResults:results];
}

@end
