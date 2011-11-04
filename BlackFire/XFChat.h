//
//  XFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XFFriend, XFConnection;

@interface XFChat : NSObject
{
	XFFriend		*_remoteFriend;
	XFConnection	*_connection;
}

@property (nonatomic, retain) XFFriend *remoteFriend;
@property (nonatomic, assign) XFConnection *connection;

//--------------------------------------------------------------------
// Sending messages
- (void)sendMessage:(NSString *)message;

//--------------------------------------------------------------------
// Handling incoming messages

/*
 * Destroys the XFChat object
 */
- (void)closeChat;

@end
