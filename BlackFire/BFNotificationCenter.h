//
//  BFNotificationCenter.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

@class XFFriend;

@interface BFNotificationCenter : NSObject <GrowlApplicationBridgeDelegate>
{
	NSMutableDictionary *_remoteFriends;
	
	NSSound *_connectSound;
	NSSound *_onlineSound;
	NSSound *_offlineSound;
	NSSound *_receiveSound;
	NSSound *_sendSound;
	
	NSUInteger _badgeCount;
}

+ (id)defaultNotificationCenter;

//-------------------------------------------------------------------------------
// Sounds

- (void)playConnectedSound;
- (void)playOnlineSound;
- (void)playOfflineSound;
- (void)playReceivedSound;
- (void)playSendSound;

//-------------------------------------------------------------------------------
// Growl

- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body;
- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body forChatFriend:(XFFriend *)remoteFriend;
- (void)postNotificationWithTitle:(NSString *)notificationTitle body:(NSString *)body context:(id)context;


//------------------------------------------------------------------------------
// Dock Icon
- (void)addBadgeCount:(NSUInteger)add;
- (void)deleteBadgeCount:(NSUInteger)remove;

@end
