//
//  ADMessageCell.m
//  BubbleTest
//
//  Created by Antwan van Houdt on 11/30/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADMessageCell.h"
#import "AHHyperlinkScanner.h"

@implementation ADMessageCell

@synthesize type = _type;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	cellFrame.size.width += 5;
	NSRect originalFrame = cellFrame;
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow setShadowColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.9]];
	
	NSFont *font = [NSFont fontWithName:@"Helvetica" size:13.0f];
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
								font,NSFontAttributeName,
								shadow,NSShadowAttributeName,
								nil];
	NSAttributedString *storage = [[NSAttributedString alloc] initWithString:[self stringValue] attributes:attributes];
	[attributes release];
	cellFrame.origin.y		+= 2;
	cellFrame.size.height	-= 4;
	
	
	// load the required resources
	NSImage *leftUp,*rightUp,*fillUp;
	NSImage *fillLeft,*fillCenter,*fillRight;
	NSImage *leftDown,*rightDown,*fillDown;
	
	if( ! _type )
	{
		leftUp		= [NSImage imageNamed:@"blue.up.left"];
		rightUp		= [NSImage imageNamed:@"blue.up.right"];
		fillUp		= [NSImage imageNamed:@"blue.up.fill"];
		
		fillLeft		= [NSImage imageNamed:@"blue.left.fill"];
		fillCenter		= [NSImage imageNamed:@"blue.center.fill"];
		fillRight		= [NSImage imageNamed:@"blue.right.fill"];
		
		leftDown	= [NSImage imageNamed:@"blue.down.left"];
		rightDown	= [NSImage imageNamed:@"blue.down.right"];
		fillDown	= [NSImage imageNamed:@"blue.down.fill"];
	}
	else 
	{
		leftUp		= [NSImage imageNamed:@"gray.up.left"];
		rightUp		= [NSImage imageNamed:@"gray.up.right"];
		fillUp		= [NSImage imageNamed:@"gray.up.fill"];
		
		fillLeft		= [NSImage imageNamed:@"gray.left.fill"];
		fillCenter		= [NSImage imageNamed:@"gray.center.fill"];
		fillRight		= [NSImage imageNamed:@"gray.right.fill"];
		
		leftDown	= [NSImage imageNamed:@"gray.down.left"];
		rightDown	= [NSImage imageNamed:@"gray.down.right"];
		fillDown	= [NSImage imageNamed:@"gray.down.fill"];
	}
	
	if( cellFrame.size.height <= 31 )
	{
		cellFrame.size.width = [storage size].width + 30;
		if( cellFrame.size.width <= 38 )
		{
			cellFrame.size.width = 40;
		}
		if( ! _type )
		{
			cellFrame.origin.x = originalFrame.size.width-cellFrame.size.width;
		}
	}
	
	NSDrawNinePartImage(cellFrame, leftUp, fillUp, rightUp, fillLeft, fillCenter, fillRight, leftDown, fillDown, rightDown, NSCompositeSourceOver, 1.0f, true);
	
	if( _type )
	{
		cellFrame.origin.x+=8;
	}
	
	if( [storage length] > 0 )
	{
		AHHyperlinkScanner *scanner = [[AHHyperlinkScanner alloc] initWithAttributedString:storage usingStrictChecking:false];
		NSAttributedString *final = [scanner linkifiedString];
		[scanner release];
		CGFloat baseY = cellFrame.origin.y+5;
		[final drawInRect:NSMakeRect(cellFrame.origin.x+10, baseY, cellFrame.size.width-30, cellFrame.size.height-10)];
	}
	[storage release];
}

@end
