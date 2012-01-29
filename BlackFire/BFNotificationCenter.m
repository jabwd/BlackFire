//
//  BFNotificationCenter.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFNotificationCenter.h"
#import "BFDefaults.h"
#import "XFFriend.h"
#import "BFSoundSet.h"

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
		_remoteFriends = [[NSMutableDictionary alloc] init];
		
		if( [[NSUserDefaults standardUserDefaults] objectForKey:BFSoundSetPath] )
		{
			BFSoundSet *soundSet = [[BFSoundSet alloc] initWithContentsOfFile:[[NSUserDefaults standardUserDefaults] objectForKey:BFSoundSetPath]];
			[self setSoundSet:soundSet];
			[soundSet release];
		}
	}
	return self;
}

- (void)dealloc
{
	[_remoteFriends release];
	_remoteFriends = nil;
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

- (void)setSoundSet:(BFSoundSet *)soundSet
{
	if( soundSet.connectedSoundPath )
	{
		[_connectSound release];
		_connectSound = [[NSSound alloc] initWithContentsOfFile:soundSet.connectedSoundPath byReference:false];
	}
	
	if( soundSet.offlineSoundPath )
	{
		[_offlineSound release];
		_offlineSound = [[NSSound alloc] initWithContentsOfFile:soundSet.offlineSoundPath byReference:false];
	}
	
	if( soundSet.onlineSoundPath )
	{
		[_onlineSound release];
		_onlineSound = [[NSSound alloc] initWithContentsOfFile:soundSet.onlineSoundPath byReference:false];
	}
	
	if( soundSet.sendSoundPath )
	{
		[_sendSound release];
		_sendSound = [[NSSound alloc] initWithContentsOfFile:soundSet.sendSoundPath byReference:false];
	}
	
	if( soundSet.receiveSoundPath )
	{
		[_receiveSound release];
		_receiveSound = [[NSSound alloc] initWithContentsOfFile:soundSet.receiveSoundPath byReference:false];
	}
	[self updateSoundVolume];
}

- (CGFloat)soundVolume
{
	return ([[NSUserDefaults standardUserDefaults] floatForKey:BFSoundVolume]/100);
}

- (void)updateSoundVolume
{
	CGFloat volume = [self soundVolume];
	
	_sendSound.volume		= volume;
	_receiveSound.volume	= volume;
	_onlineSound.volume		= volume;
	_offlineSound.volume	= volume;
	_connectSound.volume	= volume;
}

- (void)playConnectedSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableConnectSound] )
		return;
	
	if( ! _connectSound )
	{
		_connectSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"connected" ofType:@"m4v"] byReference:false];
		_connectSound.volume = [self soundVolume];
	}
	if( [_connectSound isPlaying] )
	{
		[_connectSound stop];
	}
	[_connectSound play];
}


- (void)playOnlineSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableFriendOnlineStatusSound] )
		return;
	
	if( ! _onlineSound )
	{
		_onlineSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"online" ofType:@"m4v"] byReference:false];
		_onlineSound.volume = [self soundVolume];
	}
	if( [_onlineSound isPlaying] )
	{
		[_onlineSound stop];
	}
	
	[_onlineSound play];
}


- (void)playOfflineSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableFriendOnlineStatusSound] )
		return;
	
	if( ! _offlineSound )
	{
		_offlineSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"offline" ofType:@"m4v"] byReference:false];
		_offlineSound.volume = [self soundVolume];
	}
	if( [_offlineSound isPlaying] )
	{
		[_offlineSound stop];
	}
	
	[_offlineSound play];
}


- (void)playReceivedSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableReceiveSound] )
		return;
	
	if( ! _receiveSound )
	{
		_receiveSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"receive" ofType:@"m4v"] byReference:false];
		_receiveSound.volume = [self soundVolume];
	}
	
	if( [_receiveSound isPlaying] )
	{
		[_receiveSound stop];
	}
	
	[_receiveSound play];
}


- (void)playSendSound
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFEnableSendSound] )
		return;
	
	if( ! _sendSound )
	{
		_sendSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Send" ofType:@"m4v"] byReference:false];
		_sendSound.volume = [self soundVolume];
	}
	if( [_sendSound isPlaying] )
	{
		[_sendSound stop];
	}
	
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

- (void)growlNotificationTimedOut:(id)clickContext
{
	if( clickContext && [clickContext isKindOfClass:[NSString class]] && [clickContext length] > 0 )
	{
		[_remoteFriends removeObjectForKey:clickContext];
	}
}

- (void)growlNotificationWasClicked:(id)clickContext
{
	if( clickContext && [clickContext isKindOfClass:[NSString class]] && [clickContext length] > 0 )
	{
		XFFriend *remoteFriend = [[_remoteFriends objectForKey:clickContext] retain];
		[_remoteFriends removeObjectForKey:clickContext];
		if( remoteFriend )
			[[NSNotificationCenter defaultCenter] postNotificationName:@"chatFriendClicked" object:remoteFriend];
		[remoteFriend release];
	}
	else
	{
		NSLog(@"*** Growl notification was clicked with unknown click context %@",clickContext);
	}
}

- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body
{
	[self postNotificationWithTitle:notificationTitle body:body context:nil];
}

- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body forChatFriend:(XFFriend *)remoteFriend;
{
	if( remoteFriend )
	{
		if( ! [_remoteFriends objectForKey:remoteFriend.username] )
			[_remoteFriends setObject:remoteFriend forKey:remoteFriend.username];
		[self postNotificationWithTitle:notificationTitle body:body context:remoteFriend.username];
	}
}

- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body context:(id)context
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
     clickContext:context];
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
