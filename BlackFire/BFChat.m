//
//  BFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChat.h"
#import "BFChatWindowController.h"

@implementation BFChat

@synthesize windowController = _windowController;

- (id)initWithChat:(XFChat *)chat
{
	if( (self = [super init]) )
	{
		_chat = [chat retain];
		_messages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_chat release];
	_chat = nil;
	[_messages release];
	_messages = nil;
	[super dealloc];
}

#pragma mark - XFChat Delegate

- (void)receivedMessage:(NSString *)message
{
	NSDictionary *newMessage = [[NSDictionary alloc] initWithObjectsAndKeys:message,@"message",[NSDate date],@"date", nil];
	
	[_messages addObject:newMessage];
	
	[newMessage release];
}

#pragma mark - Accessing messages

- (NSUInteger)messageCount
{
	return [_messages count];
}

- (NSDictionary *)messageAtIndex:(NSUInteger)idx
{
	return [_messages objectAtIndex:idx];
}
@end
