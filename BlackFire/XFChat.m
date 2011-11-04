//
//  XFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFChat.h"

@implementation XFChat

@synthesize remoteFriend	= _remoteFriend;
@synthesize connection		= _connection;

- (id)initWithRemoteFriend:(XFFriend *)remoteFriend 
{
	if( (self = [super init]) )
	{
		_remoteFriend	= [remoteFriend retain];
		_connection		= nil;
	}
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_remoteFriend	= nil;
		_connection		= nil;
	}
	return self;
}

- (void)dealloc
{
	[_remoteFriend release];
	_remoteFriend = nil;
	_connection = nil;
	[super dealloc];
}

#pragma mark - Sending messages

- (void)sendMessage:(NSString *)message
{
	if( [message length] > 0 )
	{
		
	}
}

#pragma mark - Handling incoming messages

#pragma mark - Misc

- (void)closeChat
{
	
}

@end
