//
//  BFChat.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFChat.h"

@interface BFChat : NSObject <XFChatDelegate>
{
	XFChat *_chat;
	
	NSMutableArray *_messages;
}

- (id)initWithChat:(XFChat *)chat;

//--------------------------------------------------------------------
// accessing messages

- (NSUInteger)messageCount;
- (NSDictionary *)messageAtIndex:(NSUInteger)idx;
@end
