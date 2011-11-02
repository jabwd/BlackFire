//
//  XFConnection.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFConnection.h"
#import "XfireKit.h"
#import "XFPacket.h"

@implementation XFConnection

@synthesize status = _status;

- (id)init
{
	if( (self = [super init]) )
	{
		_session	= nil;
		_socket		= nil;
		_status		= XFConnectionDisconnected;
	}
	return self;
}

- (void)dealloc
{
	[_socket setDelegate:nil];
	[_socket release];
	_socket = nil;
	_status = XFConnectionDisconnected;
	_session = nil;
	[super dealloc];
}

#pragma mark - Connecting

- (void)connect
{
	if( _status != XFConnectionDisconnected )
		return;
	
	[_socket release]; // prevent leaking
	_socket = nil;
	
	_status			= XFConnectionStarting;
	_socket			= [[Socket alloc] initWithDelegate:self];
	_socket.port	= XFIRE_PORT;
	[_socket connectToHost:XFIRE_ADDRESS];
	
	[self performSelector:@selector(connectionTimedOut) withObject:nil afterDelay:10.0f];
}

- (void)disconnect
{
	_status = XFConnectionDisconnected;
	[_socket release];
	_socket = nil;
}

- (void)connectionTimedOut
{
	if( _status != XFConnectionDisconnected && _status != XFConnectionStopping )
	{
		[self disconnect];
	}
}

- (void)didDisconnectWithReason:(SocketError)reason
{
	_status = XFConnectionDisconnected;
	[_socket release];
	_socket = nil;
}

#pragma mark - Sending and receiving data

- (void)sendData:(NSData *)data
{
	if( _status != XFConnectionConnected )
	{
		NSLog(@"*** Tried sending data of length %lu over disconnected XFConnection",[data length]);
		return;
	}
	[_socket sendData:data];
}

- (void)receivedData:(NSData *)data
{
	// process the data
}

- (void)sendPacket:(XFPacket *)packet
{
	[self sendData:packet.data];
}

@end
