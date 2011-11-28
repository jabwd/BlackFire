//
//  BFGamesManager.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFGamesManager.h"

@implementation BFGamesManager


- (NSImage *)imageForGame:(NSUInteger)gameID
{
	if( gameID > 0 )
	{
		NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"%lu",gameID]];
		if( ! image )
			image = [NSImage imageNamed:@"-1"];
		return image;
	}
	return [NSImage imageNamed:@"-1"];
}

@end
