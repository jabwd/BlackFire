//
//  CTTabStripView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "CTTabStripView.h"

@implementation CTTabStripView

- (id)initWithFrame:(NSRect)frame
{
    if( (self = [super initWithFrame:frame]) )
	{
		
	}
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
	NSRectFillUsingOperation(NSMakeRect(0, dirtyRect.size.height-23, dirtyRect.size.width, 1), NSCompositeSourceOver);
	
	[[NSColor colorWithCalibratedWhite:0xf7/255.0 alpha:1.0] set];
	NSRectFillUsingOperation(NSMakeRect(0, dirtyRect.size.height-24, dirtyRect.size.width, 1), NSCompositeSourceOver);
	
	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:.84 green:.84 blue:.84 alpha:1.0], 0.1, // start color
							[NSColor colorWithCalibratedRed:.917 green:.917 blue:.917 alpha:1.0], 0.80, // glow
							nil];
	[gradient drawInRect:NSMakeRect(0, 0, dirtyRect.size.width, dirtyRect.size.height-24) angle:90.0f];
	[gradient release];
	
	[[NSColor colorWithCalibratedWhite:0.68 alpha:1.0f] set];
	NSRectFillUsingOperation(NSMakeRect(0, 0, dirtyRect.size.width, 1), NSCompositeSourceOver);
	
	return;
	NSRect borderRect, contentRect;
	
	//borderRect = NSMakeRect(0, 25, dirtyRect.size.width, dirtyRect.size.height-25);
	
	borderRect = [self bounds];
	borderRect.origin.y = 1;
	borderRect.size.height = 1;
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
	NSRectFillUsingOperation(borderRect, NSCompositeSourceOver);
	NSDivideRect([self bounds], &borderRect, &contentRect, 1, NSMinYEdge);

	
	NSColor* bezelColor = [NSColor colorWithCalibratedWhite:0xf7/255.0
													  alpha:1.0];
	[bezelColor set];
	NSRectFill(borderRect);
	NSRectFillUsingOperation(borderRect, NSCompositeSourceOver);
}

@end
