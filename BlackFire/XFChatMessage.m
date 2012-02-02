//
//  XFChatMessage.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/2/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "XFChatMessage.h"

@implementation XFChatMessage

@synthesize packet = _packet;
@synthesize index = _index;

- (id)initWithIndex:(unsigned int)index packet:(XFPacket *)packet
{
	if( (self = [super init]) )
	{
		_packet = [packet retain];
		_index	= index;
	}
	return self;
}

- (void)dealloc
{
	[_packet release];
	_packet = nil;
	[super dealloc];
}

@end
