//
//  EXOutlineView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 8/13/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import "ADOutlineView.h"


@implementation ADOutlineView

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
{
	NSRect cellFrame		= [super frameOfCellAtColumn:column row:row];
	cellFrame.size.width	+= cellFrame.origin.x - 8;
	cellFrame.origin.x		= 8;
	return cellFrame;
}

/*- (void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect
{
	[[NSColor redColor] set];
	NSRectFill(clipRect);
	[super drawRow:row clipRect:clipRect];
}*/

/*
 * This draws our nice "iOS" like highlight on the selection of a row.
 * OS X Just doesn't look as nice :D
 */
/*- (void)highlightSelectionInClipRect:(NSRect)rect
{
	NSGradient *gradient;
	NSUInteger row		= [self selectedRow];
	NSRect cellFrame	= [self rectOfRow:row];
	if( [[self window] isMainWindow] )
	{
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.41f green:0.48f blue:1.0f alpha:1.0f]
												 endingColor:[NSColor colorWithCalibratedRed:0.22f green:0.27f blue:0.99f alpha:1.0f]];
		[gradient drawInRect:cellFrame angle:90.0f];
		[[NSColor colorWithCalibratedRed:0.34f green:0.40f blue:0.95f alpha:1.0f] set];
		NSRectFill(NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, 0.5f));
		
		[[NSColor colorWithCalibratedRed:0.19f green:0.19f blue:0.95f alpha:1.0f] set];
		NSRectFill(NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+cellFrame.size.height-1.0f, cellFrame.size.width, 1.0f));
	}
	else
	{
		gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.8f green:0.8f blue:0.8f alpha:1.0f]
												 endingColor:[NSColor colorWithCalibratedRed:0.6f green:0.6f blue:0.6f alpha:1.0f]];
		[gradient drawInRect:cellFrame angle:90.0f];
		[[NSColor colorWithCalibratedRed:0.70f green:0.70f blue:0.70f alpha:1.0f] set];
		NSRectFill(NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, 1.0f));
		[[NSColor colorWithCalibratedRed:0.55f green:0.55f blue:0.55f alpha:1.0f] set];
		NSRectFill(NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+cellFrame.size.height-1.0f, cellFrame.size.width, 1.0f));
	}
	[gradient release];
}*/
     
@end