//
//  XFGame.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/20/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFGame.h"

@implementation XFGame

@synthesize longName = _longName;
@synthesize shortName = _shortName;
@synthesize gameID = _gameID;

- (void)dealloc
{
	[_longName release];
	_longName = nil;
	[_shortName release];
	_shortName = nil;
	[super dealloc];
}

@end
