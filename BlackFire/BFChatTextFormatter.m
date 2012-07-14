//
//  BFChatTextFormatter.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/22/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFChatTextFormatter.h"
#import "BFChatLog.h"

@implementation BFChatTextFormatter
{
	BFChatLog *_chatLog;
}

- (id)initWithChatLog:(BFChatLog *)chatLog
{
	if( (self = [super init]) )
	{
		_chatLog = chatLog;
	}
	return self;
}

- (void)dealloc
{
	_chatLog = nil;
}

#pragma mark - Chat log processing

- (NSString *)plainTextFormat
{
	//NSArray *messages;
	return nil;
}

- (NSAttributedString *)attributedTextFormat
{
	NSLog(@"*** -attributedTextFormat is not implemented yet and shouldn't be used");
	return nil;
}

@end
