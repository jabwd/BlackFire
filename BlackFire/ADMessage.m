//
//  ADMessage.m
//  BubbleTest
//
//  Created by Antwan van Houdt on 2/18/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "ADMessage.h"

@implementation ADMessage

@synthesize timestamp = _timestamp;
@synthesize message = _message;
@synthesize type = _type;

- (void)dealloc
{
	[_message release];
	_message = nil;
	[_timestamp release];
	_timestamp = nil;
	[super dealloc];
}

@end
