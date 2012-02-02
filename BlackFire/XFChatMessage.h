//
//  XFChatMessage.h
//  BlackFire
//
//  Created by Antwan van Houdt on 2/2/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//
//	the only use for this class is to determine whether
//	this message was sent properly or not

#import <Foundation/Foundation.h>

@class XFPacket;

@interface XFChatMessage : NSObject
{
	XFPacket *_packet;
	unsigned int _index;
}

@property (readonly) XFPacket *packet;
@property (readonly) unsigned int index;

- (id)initWithIndex:(unsigned int)index packet:(XFPacket *)packet;

@end
