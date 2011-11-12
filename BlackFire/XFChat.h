//
//  XFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XFFriend, XFConnection, XFChat;

@protocol XFChatDelegate <NSObject>
- (void)receivedMessage:(NSString *)message;
@end

@interface XFChat : NSObject
{
	XFFriend		*_remoteFriend;
	XFConnection	*_connection;
	
	id <XFChatDelegate> _delegate;
}

@property (nonatomic, retain) XFFriend *remoteFriend;
@property (nonatomic, assign) XFConnection *connection;

@property (assign) id <XFChatDelegate> delegate;

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
