//
//  NSNonRetardedImageView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/24/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "NSNonRetardedImageView.h"

@implementation NSNonRetardedImageView

@synthesize image = _image;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
	[_image release];
	_image = nil;
	[super dealloc];
}

- (void)setImage:(NSImage *)image
{
	[_image release];
	_image = nil;
	_image = [image retain];
	
	[self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y+1, dirtyRect.size.width, dirtyRect.size.height-1);
	if( _image )
	{
		[NSGraphicsContext saveGraphicsState];
		[[NSColor colorWithCalibratedWhite:0.5 alpha:1.0f] set];
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow setShadowColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.41]];
		[shadow set];
		//NSRectFill(rect);
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
		[path fill];
		[NSGraphicsContext restoreGraphicsState];
		NSRect imageRect = NSMakeRect(rect.origin.x+1, rect.origin.y+1, rect.size.width-2, rect.size.height-2);
		[[NSColor whiteColor] set];
		NSRectFill(imageRect);
		[_image setSize:imageRect.size];
		[_image setScalesWhenResized:true];
		[_image drawInRect:imageRect fromRect:NSMakeRect(0, 0, imageRect.size.width, imageRect.size.height) operation:NSCompositeSourceOver fraction:1.0f];
	}
}

@end
