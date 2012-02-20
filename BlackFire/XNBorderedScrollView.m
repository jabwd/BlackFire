//
//  XNBorderedScrollView.m
//  TextFieldTest
//
//  Created by Antwan van Houdt on 2/15/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "XNBorderedScrollView.h"

@implementation XNBorderedScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if( (self = [super initWithCoder:aDecoder]) )
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidBecomeKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidResignKeyNotification object:[self window]];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) )
	{
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)update
{
	[self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)dirtyRect
{
		NSRect frame = [self bounds];
		
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(frame.origin.x+.5, frame.origin.y+.5, frame.size.width-1, frame.size.height-1) xRadius:8 yRadius:8];
		[[NSColor whiteColor] set];
		[path setLineWidth:1.0f];
		[path fill];
		
	if( [[self window] isKeyWindow] )
		[[NSColor colorWithCalibratedWhite:0.45 alpha:1.0f] set];
	else {
		[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0f] set];
	}
		[path stroke];
}


@end
