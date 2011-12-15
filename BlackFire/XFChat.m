//
//  XFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFChat.h"
#import "XFFriend.h"
#import "XFSession.h"
#import "XFConnection.h"
#import "XFPacket.h"

@implementation XFChat

@synthesize remoteFriend	= _remoteFriend;
@synthesize connection		= _connection;

@synthesize delegate = _delegate;

- (id)initWithRemoteFriend:(XFFriend *)remoteFriend 
{
	if( (self = [super init]) )
	{
		_remoteFriend	= [remoteFriend retain];
		_connection		= nil;
	}
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_remoteFriend	= nil;
		_connection		= nil;
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_remoteFriend release];
	_remoteFriend = nil;
	_connection = nil;
	[super dealloc];
}

#pragma mark - Handy methods

- (XFFriend *)loginIdentity
{
	return _connection.session.loginIdentity;
}

#pragma mark - Sending messages

- (void)sendMessage:(NSString *)message
{
	if( [message length] > 0 )
	{
		XFPacket *packet = [XFPacket chatInstantMessagePacketWithSID:_remoteFriend.sessionID imIndex:(unsigned int)_remoteFriend.messageIndex message:message];
		[_connection sendPacket:packet];
		
		NSUInteger messageIndex = _remoteFriend.messageIndex;
		messageIndex++;
		_remoteFriend.messageIndex = messageIndex;
	}
}

- (void)sendTypingNotification
{
	XFPacket *packet = [XFPacket chatTypingNotificationPacketWithSID:_remoteFriend.sessionID imIndex:(unsigned int)_remoteFriend.messageIndex typing:true];
	[_connection sendPacket:packet];
}

- (void)sendNetworkInformation
{
	XFPacket *packet = [XFPacket networkInfoPacketWithConn:0 nat:false sec:0 ip:0 naterr:0 uPnPInfo:@""];
	[_connection sendPacket:packet];
}

#pragma mark - Handling incoming messages

- (void)receivedMessage:(NSString *)message
{
	if( [_delegate respondsToSelector:@selector(receivedMessage:)] )
		[_delegate receivedMessage:message];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self friendStoppedTypingNotification];
}

- (void)receivedIsTypingNotification
{
	if( [_delegate respondsToSelector:@selector(friendStartedTyping)] )
		[_delegate friendStartedTyping];
	
	[self performSelector:@selector(friendStoppedTypingNotification) withObject:nil afterDelay:10.0f];
}

- (void)friendStoppedTypingNotification
{
	if( [_delegate respondsToSelector:@selector(friendStoppedTyping)] )
		[_delegate friendStoppedTyping];
}

- (void)receivedNetworkInformation
{
	
}


- (void)receivedPacket:(XFPacket *)packet
{
	// decode the packet and notify the XFChat object
	XFPacketDictionary *peermsg = (XFPacketDictionary *)[[packet attributeForKey:XFPacketPeerMessageKey] value];
	switch( [[[peermsg objectForKey:XFPacketMessageTypeKey] value] intValue] )
	{
		case 0: // chat message
		{
			unsigned long imIndex = [[[peermsg objectForKey:XFPacketIMIndexKey] value] longLongValue];
			NSString *message = [[peermsg objectForKey:XFPacketIMKey] value];
			[self receivedMessage:message];
			XFPacket *sendPkt = [XFPacket chatAcknowledgementPacketWithSID:[_remoteFriend sessionID] 
																   imIndex:(unsigned int)imIndex];
			[_connection sendPacket:sendPkt];
		}
			break;
			
		case 1: // acknowledgement
		{
			//NSUInteger idx = [[[peermsg objectForKey:XFPacketIMIndexKey] value] intValue];
			// TODO: handle this
		}
			break;
			
		case 2: 
		{
			// for PTP connections
		}
			break;
			
		case 3: // typing notification
			[self receivedIsTypingNotification];
			break;
	}
}

#pragma mark - Misc

- (void)closeChat
{
	[_connection.session closeChat:self];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<XFChat with %@>",[_remoteFriend displayName]];
}

@end
