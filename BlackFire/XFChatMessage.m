//
//  XFChatMessage.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/2/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "XFChatMessage.h"
#import "XFPacket.h"

@implementation XFChatMessage


- (id)initWithIndex:(NSUInteger)index packet:(XFPacket *)packet
{
	if( (self = [super init]) )
	{
		_packet = packet;
		_index	= index;
	}
	return self;
}


@end
