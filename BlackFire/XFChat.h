//
//  XFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XFFriend, XFConnection, XFChat;

@protocol XFChatDelegate <NSObject>

@end

@interface XFChat : NSObject
{
	XFFriend		*_remoteFriend;
	XFConnection	*_connection;
}

@property (nonatomic, retain) XFFriend *remoteFriend;
@property (nonatomic, assign) XFConnection *connection;

- (id)initWithRemoteFriend:(XFFriend *)remoteFriend;

//--------------------------------------------------------------------
// Sending messages
- (void)sendMessage:(NSString *)message;
- (void)notifyIsTyping;
- (void)sendNetworkInformation;

//--------------------------------------------------------------------
// Handling incoming messages
- (void)receivedNetworkInformation;
- (void)receivedIsTypingNotification;
- (void)receivedMessage:(NSString *)message;

/*
 * Destroys the XFChat object
 */
- (void)closeChat;

@end
