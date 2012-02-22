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
@synthesize borderColor = _borderColor;

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
	[_borderColor release];
	_borderColor = nil;
	[super dealloc];
}

- (void)setImage:(NSImage *)image
{
	[_image release];
	_image = nil;
	_image = [image retain];
	
	[_borderColor release];
	_borderColor = nil;
	_borderColor = [[self proposedBorderColorForImage:_image] retain];
	
	[self setNeedsDisplay:true];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y+1, dirtyRect.size.width, dirtyRect.size.height-1);
	if( _image )
	{
		[NSGraphicsContext saveGraphicsState];
		if( ! _borderColor )
			[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0f] set];
		else {
			[_borderColor set];
		}
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow setShadowColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.37]];
		[shadow set];
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

#pragma mark - Image processing

- (NSColor *)proposedBorderColorForImage:(NSImage *)image
{
	if( ! image )
		return nil;
	
	// just in case we have more than 1 representation,
	// try to find the bitmap image rep.
	NSArray *reps = [image representations];
	for(NSImageRep *rep in reps)
	{
		if( [rep isKindOfClass:[NSBitmapImageRep class]] )
		{
			NSSize imageSize = [image size];
			NSBitmapImageRep *bitmap = (NSBitmapImageRep *)rep;
			NSColor *first	= [bitmap colorAtX:0 y:0];
			NSColor *second = [bitmap colorAtX:(imageSize.width-1) y:(imageSize.height-1)];
			if( [[first colorSpace] colorSpaceModel] != NSRGBColorSpaceModel )
			{
				NSLog(@"*** Weird color space detected, falling back to default border color");
				return nil; // don't return an actual color, the drawing method will take care of this..
			}
			
			// get all the different components
			CGFloat blueTotal	= ([first blueComponent] + [second blueComponent])/2;
			CGFloat redTotal	= ([first redComponent] + [second redComponent])/2;
			CGFloat greenTotal	= ([first greenComponent] + [second greenComponent])/2;
			CGFloat alphaTotal	= ([first alphaComponent] + [second alphaComponent])/2;
			
			// calculate the actual brightness
			CGFloat white = 0.0f, brightness = ((blueTotal + redTotal + greenTotal)/3);
			brightness += (1-alphaTotal);
			if( brightness > 0.3 )
			{
				white = brightness-0.3f;
			}
			else
				white = 0.07f;
			
			if( white > 0.5 )
				white = 0.5f;
			
			return [NSColor colorWithCalibratedWhite:white alpha:1.0f];
		}
	}
	NSLog(@"*** Unable to process %@, falling back to the default image border color",image);
	return nil;
}

@end
