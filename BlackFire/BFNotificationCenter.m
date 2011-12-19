//
//  BFNotificationCenter.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFNotificationCenter.h"
#import "BFDefaults.h"

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
		[GrowlApplicationBridge setGrowlDelegate:self];
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
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableConnectSound] )
		return;
	
	if( ! _connectSound )
		_connectSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connected" ofType:@"m4v"] byReference:false];
	if( [_connectSound isPlaying] )
		return;
	
	[_connectSound play];
}


- (void)playOnlineSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableOnlineSound] )
		return;
	
	if( ! _onlineSound )
		_onlineSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"online" ofType:@"m4v"] byReference:false];
	if( [_onlineSound isPlaying] )
		return;
	
	[_onlineSound play];
}


- (void)playOfflineSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableOfflineSound] )
		return;
	
	if( ! _offlineSound )
		_offlineSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"offline" ofType:@"m4v"] byReference:false];
	if( [_offlineSound isPlaying] )
		return;
	
	[_offlineSound play];
}


- (void)playReceivedSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableReceiveSound] )
		return;
	
	if( ! _receiveSound )
		_receiveSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"receive" ofType:@"m4v"] byReference:false];
	
	if( [_receiveSound isPlaying] )
		return;
	
	[_receiveSound play];
}


- (void)playSendSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableSendSound] )
		return;
	
	if( ! _sendSound )
		_sendSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Send" ofType:@"m4v"] byReference:false];
	if( [_sendSound isPlaying] )
		return;
	
	[_sendSound play];
}


#pragma mark - Growl

- (NSString *)applicationNameForGrowl
{
	return @"BlackFire";
}

- (NSDictionary *)registrationDictionaryForGrowl 
{
	NSArray *notes = [[NSArray alloc] initWithObjects:
					  @"Normal",
					  nil];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:notes,GROWL_NOTIFICATIONS_ALL,
						  notes,GROWL_NOTIFICATIONS_DEFAULT,
						  nil];
	[notes release];
	return dict;
}

- (void)growlIsReady
{
	
}

- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableNotifications] )
		return;
	
	
	[GrowlApplicationBridge
     notifyWithTitle:notificationTitle
     description:body
     notificationName:@"Normal"
     iconData:nil
     priority:0
     isSticky:NO
     clickContext:nil];
}

#pragma mark - Badge count

- (void)addBadgeCount:(NSUInteger)add
{
	_badgeCount += add;
	
	[[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%lu",_badgeCount]];
}

- (void)deleteBadgeCount:(NSUInteger)remove
{
	if( remove > _badgeCount )
	{
		_badgeCount = 0;
	}
	else
	{
		_badgeCount -= remove;
	}
	
	if( _badgeCount == 0 )
	{
		[[NSApp dockTile] setBadgeLabel:nil];
	}
	else
	{
		[[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%lu",_badgeCount]];
	}
}

@end
