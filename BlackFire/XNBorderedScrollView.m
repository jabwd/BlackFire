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
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
	if( [[self window] isKeyWindow] )
	{
		[[NSColor colorWithCalibratedWhite:0.45 alpha:1.0f] set];
	}
	else
	{
		[[NSColor colorWithCalibratedWhite:0.65 alpha:1.0f] set];
	}
	NSRectFillUsingOperation(dirtyRect,NSCompositeSourceOver);
}

@end
