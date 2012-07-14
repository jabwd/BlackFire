//
//  XFGame.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/20/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFGame.h"

@implementation XFGame


- (id)initWithLongName:(NSString *)longName shortName:(NSString *)shortName gameID:(unsigned int)gameID
{
	if( (self = [super init]) )
	{
		_longName	= longName;
		_shortName	= shortName;
		_gameID		= gameID;
	}
	return self;
}


@end
