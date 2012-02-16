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
#import "ADBitList.h"
#import "XFChatMessage.h"

@implementation XFChat

@synthesize remoteFriend	= _remoteFriend;
@synthesize connection		= _connection;

@synthesize delegate = _delegate;

- (id)initWithRemoteFriend:(XFFriend *)remoteFriend 
{
	if( (self = [super init]) )
	{
		_remoteFriend		= [remoteFriend retain];
		_connection			= nil;
		_messageBuffer		= [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_remoteFriend		= nil;
		_connection			= nil;
		_messageBuffer		= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_remoteFriend release];
	_remoteFriend = nil;
	_connection = nil;
	[_messageBuffer release];
	_messageBuffer = nil;
	[super dealloc];
}

#pragma mark - Handy methods

- (XFFriend *)loginIdentity
{
	return _connection.session.loginIdentity;
}

#pragma mark - Sending messages

- (void)messageTimedOut:(XFChatMessage *)message
{
	if( message )
	{
		if( [_delegate respondsToSelector:@selector(messageDidTimeout)] )
			[_delegate messageDidTimeout];
		
		[_messageBuffer removeObject:message];
	}
}

- (void)sendMessage:(NSString *)message
{
	if( [message length] > 0 )
	{
		NSUInteger messageIndex = _remoteFriend.messageIndex;
		XFPacket *packet = [XFPacket chatInstantMessagePacketWithSID:_remoteFriend.sessionID imIndex:(unsigned int)messageIndex message:message];
		[_connection sendPacket:packet];
		
		XFChatMessage *message = [[XFChatMessage alloc] initWithIndex:messageIndex packet:packet];
		[_messageBuffer addObject:message];
		[self performSelector:@selector(messageTimedOut:) withObject:message afterDelay:15.0f];
		[message release];
		
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
	if( [message length] < 1 )
		return;
	
	
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
			unsigned long imIndex = (unsigned long)[[[peermsg objectForKey:XFPacketIMIndexKey] value] longLongValue];
			NSString *message = [[peermsg objectForKey:XFPacketIMKey] value];
			if( [_remoteFriend.receivedMessages isSet:(unsigned int)imIndex] )
			{
				NSLog(@"[Notice] Received a duplicate chat message\n\n '%@'\n\n with index: %lu",message,imIndex);
			}
			else
			{
				[self receivedMessage:message];
				[_remoteFriend.receivedMessages set:(unsigned int)imIndex];
			}
			XFPacket *sendPkt = [XFPacket chatAcknowledgementPacketWithSID:[_remoteFriend sessionID] 
																   imIndex:(unsigned int)imIndex];
			[_connection sendPacket:sendPkt];
		}
			break;
			
		case 1: // acknowledgement
		{
			NSUInteger idx = [[[peermsg objectForKey:XFPacketIMIndexKey] value] intValue];
			NSInteger i, cnt = [_messageBuffer count];
			for(i=0;i<cnt;i++)
			{
				XFChatMessage *message = [_messageBuffer objectAtIndex:i];
				if( message.index == idx )
				{
					[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(messageTimedOut:)object:message];
					[_messageBuffer removeObjectAtIndex:i];
					return;
				}
			}
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
	
	// No code here, can cause bugs ( the switch can end this method ).
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
