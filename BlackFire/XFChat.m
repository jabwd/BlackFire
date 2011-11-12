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
	[_remoteFriend release];
	_remoteFriend = nil;
	_connection = nil;
	[super dealloc];
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

- (void)notifyIsTyping
{
	XFFriend *us = _connection.session.loginIdentity;
	XFPacket *packet = [XFPacket chatTypingNotificationPacketWithSID:us.sessionID imIndex:(unsigned int)us.messageIndex typing:true];
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
}

- (void)receivedIsTypingNotification
{
	
}

- (void)receivedNetworkInformation
{
	
}

#pragma mark - Misc

- (void)closeChat
{
	
}

@end
