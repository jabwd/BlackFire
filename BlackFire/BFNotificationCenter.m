//
//  BFNotificationCenter.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFNotificationCenter.h"
#import <Growl/Growl.h>

static BFNotificationCenter *notificationCenter = nil;

@implementation BFNotificationCenter

+ (id)defaultNotificationCenter
{
	if( ! notificationCenter )
	{
		notificationCenter = [[[self class] alloc] init];
	}
	return notificationCenter;
}

- (id)init
{
	if( (self = [super init]) )
	{
		
	}
	return self;
}

- (void)dealloc
{
	[_connectSound release];
	_connectSound = nil;
	[_sendSound release];
	_sendSound = nil;
	[_receiveSound release];
	_receiveSound = nil;
	[_offlineSound release];
	_offlineSound = nil;
	[_onlineSound release];
	_onlineSound = nil;
	[super dealloc];
}

#pragma mark - Handling sounds

- (void)playConnectedSound
{
	if( ! _connectSound )
		_connectSound = [[NSSound soundNamed:@"connected"] retain];
	if( [_connectSound isPlaying] )
		return;
	
	[_connectSound play];
}


- (void)playOnlineSound
{
	if( ! _onlineSound )
		_onlineSound = [[NSSound soundNamed:@"online"] retain];
	if( [_onlineSound isPlaying] )
		return;
	
	[_onlineSound play];
}


- (void)playOfflineSound
{
	if( ! _offlineSound )
		_offlineSound = [[NSSound soundNamed:@"offline"] retain];
	if( [_offlineSound isPlaying] )
		return;
	
	[_offlineSound play];
}


- (void)playReceivedSound
{
	if( ! _receiveSound )
		_receiveSound = [[NSSound soundNamed:@"receive"] retain];
	if( [_receiveSound isPlaying] )
		return;
	
	[_receiveSound play];
}


- (void)playSendSound
{
	if( ! _sendSound )
		_sendSound = [[NSSound soundNamed:@"send"] retain];
	if( [_sendSound isPlaying] )
		return;
	
	[_sendSound play];
}


#pragma mark - Growl

- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body
{
	
}
@end
