//
//  BFChat.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BFChat.h"

@implementation BFChat

- (id)initWithChat:(XFChat *)chat
{
	if( (self = [super init]) )
	{
		_chat = [chat retain];
	}
	return self;
}

- (void)dealloc
{
	[_chat release];
	_chat = nil;
	[super dealloc];
}
@end
