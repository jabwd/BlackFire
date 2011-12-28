//
//  CTTabView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "CTTabView.h"

#define kToolbarTopOffset 12
#define kToolbarMaxHeight 100

// Constants for inset and control points for tab shape.
const CGFloat kInsetMultiplier = 2.0/3.0;
const CGFloat kControlPoint1Multiplier = 1.0/3.0;
const CGFloat kControlPoint2Multiplier = 3.0/8.0;

// The amount of time in seconds during which each type of glow increases, holds
// steady, and decreases, respectively.
const NSTimeInterval kHoverShowDuration = 0.2;
const NSTimeInterval kHoverHoldDuration = 0.02;
const NSTimeInterval kHoverHideDuration = 0.4;
const NSTimeInterval kAlertShowDuration = 0.4;
const NSTimeInterval kAlertHoldDuration = 0.4;
const NSTimeInterval kAlertHideDuration = 0.4;

// The default time interval in seconds between glow updates (when
// increasing/decreasing).
const NSTimeInterval kGlowUpdateInterval = 0.025;

const CGFloat kTearDistance = 36.0;
const NSTimeInterval kTearDuration = 0.333;

// This is used to judge whether the mouse has moved during rapid closure; if it
// has moved less than the threshold, we want to close the tab.
const CGFloat kRapidCloseDist = 2.5;

@implementation CTTabView

- (id)initWithFrame:(NSRect)frame
{
    if( (self = [super initWithFrame:frame]) )
	{
		
	}
    return self;
}

- (void)dealloc
{
	[super dealloc];
}
 
#pragma mark - Dragging

- (void)mouseDown:(NSEvent *)theEvent
{
	_hitOrigin =  [[self superview] convertPoint:[theEvent locationInWindow]
										fromView:nil];
	_dragOrigin = [NSEvent mouseLocation];
	_originalFrame = [self frame];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint newLocation = [NSEvent mouseLocation];
	CGFloat deltaX = _dragOrigin.x - newLocation.x;
	
	NSRect ownFrame = [self frame];
	ownFrame.origin.x -= deltaX;
	[self setFrame:ownFrame];
	_dragOrigin.x = newLocation.x;
	
	[[self superview] setNeedsDisplay:true];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	[[NSAnimationContext currentContext] setDuration:0.125];
	[[self animator] setFrame:_originalFrame];
	[[self superview] setNeedsDisplay:true];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	
	NSWindow			*window		= [self window];
	NSGraphicsContext	*context	= [NSGraphicsContext currentContext];
	[context saveGraphicsState];
	
	NSRect rect			= [self bounds];
	NSBezierPath *path	= [self bezierPathForRect:rect];
    
    
	
	BOOL selected = true;
	// Don't draw the window/tab bar background when selected, since the tab
	// background overlay drawn over it (see below) will be fully opaque.
	if (!selected) {
		// Use the window's background color rather than |[NSColor
		// windowBackgroundColor]|, which gets confused by the fullscreen window.
		// (The result is the same for normal, non-fullscreen windows.)
		if( true )
		{
			if( [[self window] isKeyWindow] )
			{
				NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:.79 green:.79 blue:.79 alpha:1.0], 0.1, // start color
										[NSColor colorWithCalibratedRed:.84 green:.84 blue:.84 alpha:1.0], 0.80, // glow
										nil];
				[gradient drawInBezierPath:path angle:90.0f];
                [gradient release];
			}
			else
			{
				NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:.87 green:.87 blue:.87 alpha:1.0], 0.1, // start color
										[NSColor colorWithCalibratedRed:.92 green:.92 blue:.92 alpha:1.0], 0.80, // glow
										nil];
				[gradient drawInBezierPath:path angle:90.0f]; 
                [gradient release];
			}
		}
		else
		{
            if( false )
            {
                // draw a hover
                NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:.98 green:.98 blue:.98 alpha:1.0], 0.1, // start color
                                        [NSColor colorWithCalibratedRed:.83 green:.83 blue:.83 alpha:1.0], 0.80, // glow
                                        nil];
                [gradient drawInBezierPath:path angle:90.0f]; 
                [gradient release];
                [[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] set];
                [path fill];
            }
            else
            {
                NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:.95 green:.95 blue:.95 alpha:1.0], 0.1, // start color
                                        [NSColor colorWithCalibratedRed:.80 green:.80 blue:.80 alpha:1.0], 0.80, // glow
                                        nil];
                [gradient drawInBezierPath:path angle:90.0f];
                [gradient release];
                [[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] set];
                [path fill];
            }
			
		}
	}
	
	[context saveGraphicsState];
	[path addClip];
	
	// Use the same overlay for the selected state and for hover and alert glows;
	// for the selected state, it's fully opaque.
	CGFloat hoverAlpha = 1.0f;
	CGFloat alertAlpha = 1.0f;
	if (selected || hoverAlpha > 0 || alertAlpha > 0) {
		// Draw the selected background / glow overlay.
		[context saveGraphicsState];
		CGContextRef cgContext = (CGContextRef)[context graphicsPort];
		CGContextBeginTransparencyLayer(cgContext, 0);
		if (!selected) 
		{
			// The alert glow overlay is like the selected state but at most at most
			// 80% opaque. The hover glow brings up the overlay's opacity at most 50%.
			CGContextSetAlpha(cgContext, ((1 - (0.8 * alertAlpha)) * 0.5 * hoverAlpha));
		}
		[path addClip];
		[context saveGraphicsState];
		
		// draw background ?
		NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:.87 green:.87 blue:.87 alpha:1.0], 0.1, // start color
								[NSColor colorWithCalibratedRed:.927 green:.927 blue:.927 alpha:1.0], 0.80, // glow
								nil];
		[gradient drawInBezierPath:path angle:90.0f]; 
		[gradient release];
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.4] set];
		[path fill];

		[context restoreGraphicsState];
		
		// Draw a mouse hover gradient for the default themes.
		if (!selected && hoverAlpha > 0) {
			NSGradient *glow = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0
																	alpha:1.0 * hoverAlpha]
							endingColor:[NSColor colorWithCalibratedWhite:1.0
																	alpha:0.0]];
			
			NSPoint point = hoverPoint_;
			point.y = NSHeight(rect);
			[glow drawFromCenter:point
						  radius:0.0
						toCenter:point
						  radius:NSWidth(rect) / 3.0
						 options:NSGradientDrawsBeforeStartingLocation];
			
			[glow drawInBezierPath:path relativeCenterPosition:hoverPoint_];
		}
		
		CGContextEndTransparencyLayer(cgContext);
		[context restoreGraphicsState];
	}
	BOOL active = [window isKeyWindow] || [window isMainWindow];
	CGFloat borderAlpha = selected ? (active ? 0.3 : 0.2) : 0.2;
	// TODO: cache colors
	NSColor* borderColor = [NSColor colorWithDeviceWhite:0.0 alpha:borderAlpha];
	NSColor* highlightColor = [NSColor colorWithCalibratedWhite:247 alpha:1.0];
	// Draw the top inner highlight within the currently selected tab if using
	// the default theme.
	if (selected) {
		NSAffineTransform* highlightTransform = [NSAffineTransform transform];
		[highlightTransform translateXBy:1.0 yBy:-1.0];
		NSBezierPath *highlightPath = [path copy];
		[highlightPath transformUsingAffineTransform:highlightTransform];
		[highlightColor setStroke];
		[highlightPath setLineWidth:1.0];
		[highlightPath stroke];
		highlightTransform = [NSAffineTransform transform];
		[highlightTransform translateXBy:-2.0 yBy:0.0];
		[highlightPath transformUsingAffineTransform:highlightTransform];
		[highlightPath stroke];
		[highlightPath release];
	}
	
	[context restoreGraphicsState];
	
	// Draw the top stroke.
	[context saveGraphicsState];
	[borderColor set];
	[path setLineWidth:1.0];
	[path stroke];
	[context restoreGraphicsState];
	
	// Mimic the tab strip's bottom border, which consists of a dark border
	// and light highlight.
	if (!selected) {
        if( [[self window] isKeyWindow] )
        {
            NSShadow *shad = [[NSShadow alloc] init];
            [shad   setShadowColor:[NSColor colorWithCalibratedRed:.1f green:.1f blue:0.1f alpha:.7f]];
            [shad   setShadowOffset:NSMakeSize(1.0f, 1.0f)];
            [shad   setShadowBlurRadius:8.0f];
            [shad   set];
            [shad   release];
        }
		[path addClip];
		NSRect borderRect = rect;
		borderRect.origin.y = 1;
		borderRect.size.height = 1;
		[borderColor set];
		NSRectFillUsingOperation(borderRect, NSCompositeSourceOver);
		
		borderRect.origin.y = 0;
		[highlightColor set];
		NSRectFillUsingOperation(borderRect, NSCompositeSourceOver);
	}
	
	[context restoreGraphicsState];

}

- (NSBezierPath *)bezierPathForRect:(NSRect)rect 
{
	// Outset by 0.5 in order to draw on pixels rather than on borders (which
	// would cause blurry pixels). Subtract 1px of height to compensate, otherwise
	// clipping will occur.
	rect = NSInsetRect(rect, -0.5, -0.5);
	rect.size.height -= 1.0;
	
	NSPoint bottomLeft = NSMakePoint(NSMinX(rect), NSMinY(rect) + 2);
	NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect) + 2);
	NSPoint topRight =
	NSMakePoint(NSMaxX(rect) - kInsetMultiplier * NSHeight(rect),
				NSMaxY(rect));
	NSPoint topLeft =
	NSMakePoint(NSMinX(rect)  + kInsetMultiplier * NSHeight(rect),
				NSMaxY(rect));
	
	CGFloat baseControlPointOutset = NSHeight(rect) * kControlPoint1Multiplier;
	CGFloat bottomControlPointInset = NSHeight(rect) * kControlPoint2Multiplier;
	
	// Outset many of these values by 1 to cause the fill to bleed outside the
	// clip area.
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(bottomLeft.x - 1, bottomLeft.y - 2)];
	[path lineToPoint:NSMakePoint(bottomLeft.x - 1, bottomLeft.y)];
	[path lineToPoint:bottomLeft];
	[path curveToPoint:topLeft
		 controlPoint1:NSMakePoint(bottomLeft.x + baseControlPointOutset,
								   bottomLeft.y)
		 controlPoint2:NSMakePoint(topLeft.x - bottomControlPointInset,
								   topLeft.y)];
	[path lineToPoint:topRight];
	[path curveToPoint:bottomRight
		 controlPoint1:NSMakePoint(topRight.x + bottomControlPointInset,
								   topRight.y)
		 controlPoint2:NSMakePoint(bottomRight.x - baseControlPointOutset,
								   bottomRight.y)];
	[path lineToPoint:NSMakePoint(bottomRight.x + 1, bottomRight.y)];
	[path lineToPoint:NSMakePoint(bottomRight.x + 1, bottomRight.y - 2)];
	return path;
}



@end

