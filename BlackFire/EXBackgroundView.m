//
//  EXBackgroundView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/20/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "EXBackgroundView.h"

@implementation EXBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor colorWithCalibratedRed:0.8348f green:0.862f blue:0.905f alpha:1.0f] set];
	NSRectFill(dirtyRect);
	
	// 19 26 37
}

@end
