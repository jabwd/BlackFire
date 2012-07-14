//
//  ADTableRowView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/16/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "ADTableRowView.h"

@implementation ADTableRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
	if( !self.groupRowStyle )
	{
		[self.backgroundColor set];
		NSRectFill([self bounds]);
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.98f green:0.98f blue:0.98f alpha:1.0f]
															 endingColor:[NSColor colorWithCalibratedRed:0.96f green:0.96f blue:0.96f alpha:1.0f]];
		
		[gradient drawInRect:[self bounds] angle:90.0f];
	}
	else
	{
		[super drawBackgroundInRect:dirtyRect]; 
	}
}

- (void)drawSelectionInRect:(NSRect)cellFrame
{
	if( self.groupRowStyle )
	{
		[super drawSelectionInRect:cellFrame];
		return;
	}
	NSGradient *gradient;
	if( self.emphasized )
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
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect{
	if( self.groupRowStyle )
	{
		[super drawSeparatorInRect:dirtyRect];
		return;
	}
	[[NSColor colorWithCalibratedWhite:0.9f alpha:1.0f] set];
	NSRectFill([self separatorRect]);
}
- (NSRect)separatorRect {
    NSRect separatorRect = self.bounds;
    separatorRect.origin.y = NSMaxY(separatorRect) - 1;
    separatorRect.size.height = 1;
    return separatorRect;
}
@end
