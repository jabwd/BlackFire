//
//  XFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XFFriend, XFConnection, XFChat, XFPacket, ADBitList;

@protocol XFChatDelegate <NSObject>
- (void)receivedMessage:(NSString *)message;
- (void)messageDidTimeout;
- (void)friendStartedTyping;
- (void)friendStoppedTyping;
@end

@interface XFChat : NSObject

@property (nonatomic, strong) XFFriend *remoteFriend;
@property (nonatomic, unsafe_unretained) XFConnection *connection;

@property (unsafe_unretained) id <XFChatDelegate> delegate;

@property (readonly) BOOL isFriendTyping;

- (id)initWithRemoteFriend:(XFFriend *)remoteFriend;

//--------------------------------------------------------------------
// Handy methods
- (XFFriend *)loginIdentity;

//--------------------------------------------------------------------
// Sending messages
- (void)sendMessage:(NSString *)message;
- (void)sendTypingNotification;
- (void)sendNetworkInformation;

//--------------------------------------------------------------------
// Handling incoming messages
- (void)receivedNetworkInformation;
- (void)receivedIsTypingNotification;
- (void)receivedMessage:(NSString *)message;
- (void)friendStoppedTypingNotification;

- (void)receivedPacket:(XFPacket *)packet;

//---------------------------------------------------------------------
// Closing the Chat
- (void)closeChat;

@end
