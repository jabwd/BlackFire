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

// the amount of seconds before sending a keepalive request
// lower this if you are on an unstable connection
#define KEEPALIVE_TIME 60.0f

NSString *XFFriendDidChangeNotification		= @"XFFriendDidChangeNotification";
NSString *XFFriendChangeAttribute			= @"XFFriendChangeAttribute";

@implementation XFSession
{	
	NSMutableArray	*_friends;
	NSTimer			*_keepAliveTimer;
	
	NSMutableArray	*_chats;
	NSMutableArray	*_groupChats;
	
	NSMutableArray *_servers;
	
	// yeath this seems odd, but we need this in order to make sure that we aren't doing any excessive
	// work displaying growl notifications when we are still "connecting" to xfire.
	// yup, the protocol sucks.
	BOOL _canPostNotifications;
}


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
		
		_canPostNotifications = false;
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(systemWillPowerOff:) name:NSWorkspaceWillPowerOffNotification object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(systemWillSleep:) name:NSWorkspaceWillSleepNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[_keepAliveTimer invalidate];
	_keepAliveTimer = nil;
	_status = XFSessionStatusOffline;
	_delegate = nil;
	_friends = nil;
	_chats = nil;
	_groupChats = nil;
	_servers = nil;
}

- (void)connect
{
	if( _status != XFSessionStatusOffline )
	{
		NSLog(@"*** Tried to connect a session that is already connected or connecting");
		return;
	}
	
	[self setStatus:XFSessionStatusConnecting];
	
	_friends = [[NSMutableArray alloc] init];
	_groupController = [[XFGroupController alloc] init];
	
	_loginIdentity = [[XFFriend alloc] init];
	
	_tcpConnection = [[XFConnection alloc] initWithSession:self];
	[_tcpConnection connect];
	
	_chats = [[NSMutableArray alloc] init];
	
	_groupChats = [[NSMutableArray alloc] init];
	
	_canPostNotifications = false;
	
	[_keepAliveTimer invalidate];
	_keepAliveTimer = nil;
}

- (void)disconnect
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[self setStatus:XFSessionStatusDisconnecting];
	
	[_keepAliveTimer invalidate];
	_keepAliveTimer = nil;
	[_tcpConnection disconnect];
	_tcpConnection = nil;
	_groupController = nil;
	
	_loginIdentity = nil;
	
	_friends = nil;
	
	_chats = nil;
	
	_groupChats = nil;
	
	_servers = nil;
	
	[self setStatus:XFSessionStatusOffline];
}

- (void)setStatus:(XFSessionStatus)newStatus
{
	_status = newStatus;
	
	if( _status == XFSessionStatusOnline )
	{
		[self performSelector:@selector(allowNotifications) withObject:nil afterDelay:1.5f];
		//[self sendKeepAlive:_keepAliveTimer];
		[_keepAliveTimer invalidate];
		_keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:KEEPALIVE_TIME target:self selector:@selector(sendKeepAlive:) userInfo:nil repeats:true];
	}
	
	if( [_delegate respondsToSelector:@selector(session:statusChanged:)] )
	{
		[_delegate session:self statusChanged:_status];
	}
}

- (void)allowNotifications
{
	_canPostNotifications = true;
	
	// will notify the gui that it has to refresh.
	[self raiseFriendNotification:XFFriendNotificationFriendAdded forFriend:nil];
}



- (void)systemWillPowerOff:(NSNotification *)notification
{
	if( _status == XFSessionStatusOnline )
		[self disconnect];
}

- (void)systemWillSleep:(NSNotification *)notification
{
	if( _status == XFSessionStatusOnline )
		[self disconnect];
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
	if( [_delegate respondsToSelector:@selector(session:willDisconnectWithReason:)] )
		[_delegate session:self willDisconnectWithReason:connectionError];
	[self disconnect];
}

#pragma mark - Managing friends

- (void)raiseFriendNotification:(XFFriendNotification)notification forFriend:(XFFriend *)fr
{
	if( !_canPostNotifications )
		return;
	
	if( [_delegate respondsToSelector:@selector(session:friendChanged:type:)] )
		[_delegate session:self friendChanged:fr type:notification];
	else
		NSLog(@"*** Friend notification was raised but the delegate does not respond");
}

- (XFFriend *)friendForUserID:(unsigned int)userID
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [_friends[i] userID] == userID )
			return _friends[i];
	}
	return nil;
}

- (XFFriend *)friendForUsername:(NSString *)username
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[_friends[i] username] isEqualToString:username] )
			return _friends[i];
	}
	return nil;
}

- (XFFriend *)friendForSessionID:(NSData *)sessionID
{
	NSUInteger i, cnt = [_friends count];
	for(i=0;i<cnt;i++)
	{
		if( [[_friends[i] sessionID] isEqualToData:sessionID] )
			return _friends[i];
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
		if( [_friends[i] userID] == oldFriend.userID )
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
		if( [_friends[i] userID] == userID )
		{
			friend = _friends[i];
			for(XFGroup *group in _groupController.groups)
			{
				if( [group friendIsMember:friend] )
					[group removeMember:friend];
			}
			[_friends removeObjectAtIndex:i];
			break;
		}
	}
	[self raiseFriendNotification:XFFriendNotificationFriendRemoved forFriend:friend];
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
	// just to make sure that the chat isn't destroyed when we are still busy
	// removing it, we still need it in the delegate _after_ removing it from our
	// own storage
	
	NSUInteger i, cnt = [_chats count];
	for(i=0;i<cnt;i++)
	{
		XFChat *chat_ = _chats[i];
		if( chat_.remoteFriend.userID == chat.remoteFriend.userID )
		{
			[_chats removeObjectAtIndex:i];
			break;
		}
	}
	
	if( [_delegate respondsToSelector:@selector(session:chatDidEnd:)] )
		[_delegate session:self chatDidEnd:chat];
	
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

- (void)receivedFriendInformation:(unsigned int)userID getValue:(unsigned int)value type:(unsigned int)type
{
	if( [_delegate respondsToSelector:@selector(session:receivedAvatarInformation:getValue:type:)] )
		[_delegate session:self receivedAvatarInformation:userID getValue:value type:type];
}



#pragma mark - User session

- (void)updateUserSettings
{
	[_tcpConnection updateUserOptions];
}

- (void)acceptFriendRequest:(XFFriend *)fr
{
	[_tcpConnection acceptFriendRequest:fr];
}

- (void)declineFriendRequest:(XFFriend *)fr
{
	[_tcpConnection declineFriendRequest:fr];
}

- (void)sendFriendRequest:(NSString *)username message:(NSString *)message
{
	[_tcpConnection sendFriendInvitation:username message:message];
}

- (void)enterGame:(unsigned int)gameID IP:(unsigned int)IPAddress port:(unsigned short)port
{
	[_tcpConnection setGameStatus:gameID gameIP:IPAddress gamePort:port];
}

- (void)exitGame
{
	[_tcpConnection setGameStatus:0 gameIP:0 gamePort:0];
}

- (void)setStatusString:(NSString *)text
{
	if( _status == XFSessionStatusOnline )
	{
		if( ! [_loginIdentity.status isEqualToString:text] )
		{
			_loginIdentity.status = text;
			[_tcpConnection setStatusText:text];
			if( [_delegate respondsToSelector:@selector(session:userStatusChanged:)] )
			   [_delegate session:self userStatusChanged:text];
		}
	}
}

- (void)setNickname:(NSString *)text
{
	if( _status == XFSessionStatusOnline )
	{
		if( ! [_loginIdentity.nickname isEqualToString:text] )
		{
			_loginIdentity.nickname = text;
			[_tcpConnection changeNickname:text];
			
			if( [_delegate respondsToSelector:@selector(session:nicknameChanged:)] )
				[_delegate session:self nicknameChanged:text];
		}
	}
}

- (void)beginUserSearch:(NSString *)searchString
{
	if( _status == XFSessionStatusOnline )
	{
		[_tcpConnection beginUserSearch:searchString];
	}
}

- (void)sendRemoveFriend:(XFFriend *)remoteFriend
{
	if( remoteFriend )
	{
		[_tcpConnection sendRemoveFriend:remoteFriend];
		[self raiseFriendNotification:XFFriendNotificationFriendRemoved forFriend:remoteFriend];
	}
}

- (void)requestFriendInformation:(XFFriend *)remoteFriend
{
	if( remoteFriend )
	{
		[_tcpConnection requestFriendInfo:(unsigned int)remoteFriend.userID];
	}
}

@end
