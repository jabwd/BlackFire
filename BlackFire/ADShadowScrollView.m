//
//  ADShadowScrollView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ADShadowScrollView.h"

@implementation ADShadowScrollView

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	[[NSColor blackColor] set];
	NSRectFill(dirtyRect);
}

@end
