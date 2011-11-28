//
//  BFGamesManager.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFGamesManager.h"

@implementation BFGamesManager


- (NSImage *)imageForGame:(unsigned int)gameID
{
	if( gameID > 0 )
	{
		return [NSImage imageNamed:[NSString stringWithFormat:@"%lu",gameID]];
	}
	return [NSImage imageNamed:@"-1"];
}

@end
