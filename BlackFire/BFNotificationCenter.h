//
//  BFNotificationCenter.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

@interface BFNotificationCenter : NSObject <GrowlApplicationBridgeDelegate>
{
	NSSound *_connectSound;
	NSSound *_onlineSound;
	NSSound *_offlineSound;
	NSSound *_receiveSound;
	NSSound *_sendSound;
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

@end
