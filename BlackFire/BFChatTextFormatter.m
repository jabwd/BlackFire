//
//  BFChatTextFormatter.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/22/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFChatTextFormatter.h"

@implementation BFChatTextFormatter


- (id)init
{
	if( (self = [super init]) )
	{
		NSLog(@"*** You cannot initialize BFChatTextFormatter without a valid BFChatLog object.");
	}
	[self release];
	self = nil;
	return nil;
}


- (id)initWithChatLog:(BFChatLog *)chatLog
{
	if( (self = [super init]) )
	{
		_chatLog = [chatLog retain];
	}
	return self;
}

- (void)dealloc
{
	[_chatLog release];
	_chatLog = nil;
	[super dealloc];
}

#pragma mark - Chat log processing

- (NSString *)plainTextFormat
{
	return nil;
}

- (NSAttributedString *)attributedTextFormat
{
	NSLog(@"*** -attributedTextFormat is not implemented yet and shouldn't be used");
	return nil;
}

@end
