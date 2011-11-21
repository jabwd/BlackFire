//
//  SFTabView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

// TODO: Add Snow leopard support

#import "SFTabView.h"
#import "SFTabStripView.h"

@implementation SFTabView

@synthesize title = _title;
@synthesize selected = _selected;
@synthesize tag = _tag;

@synthesize target = _target;
@synthesize selector = _selector;

- (id)initWithFrame:(NSRect)frame
{
    if( (self = [super initWithFrame:frame]) )
	{
		_title = nil;
		
		_mouseInside = false;
		
		
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
		[self addTrackingArea:trackingArea];
		[trackingArea release];
		
		trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(10, 4, 12, 13) options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
		[self addTrackingArea:trackingArea];
		[trackingArea release];
	}
    return self;
}

- (void)dealloc
{
	[_title release];
	_title = nil;
	[super dealloc];
}

- (void)drawRect:(NSRect)useless
{
	NSRect dirtyRect = [self bounds];
	NSImage *left;
	NSImage *right;
	NSImage *fill;
	NSImage *close;
	if( _selected )
	{
		if( [[self window] isMainWindow] )
		{
			left	= [NSImage imageNamed:@"activeTabLeft"];
			right	= [NSImage imageNamed:@"activeTabRight"];
			fill	= [NSImage imageNamed:@"activeTabFill"];
			
			if( _mouseInsideClose )
				close = [NSImage imageNamed:@"activeTabCloseHover"];
			else
				close = [NSImage imageNamed:@"activeTabClose"];
		}
		else
		{
			left	= [NSImage imageNamed:@"activeWTabLeft"];
			right	= [NSImage imageNamed:@"activeWTabRight"];
			fill	= [NSImage imageNamed:@"activeWTabFill"];
			
			if( _mouseInsideClose )
				close = [NSImage imageNamed:@"activeWTabCloseHover"];
			else
				close = [NSImage imageNamed:@"activeWTabClose"];
		}
	}
	else
	{
		if( [[self window] isMainWindow] )
		{
			left	= [NSImage imageNamed:@"inactiveTabLeft"];
			right	= [NSImage imageNamed:@"inactiveTabRight"];
			fill	= [NSImage imageNamed:@"inactiveTabFill"];
			
			if( _mouseInsideClose )
				close = [NSImage imageNamed:@"inactiveTabCloseHover"];
			else
				close = [NSImage imageNamed:@"inactiveTabClose"];
		}
		else
		{
			left	= [NSImage imageNamed:@"inactiveWTabLeft"];
			right	= [NSImage imageNamed:@"inactiveWTabRight"];
			fill	= [NSImage imageNamed:@"inactiveWTabFill"];
			
			if( _mouseInsideClose )
				close = [NSImage imageNamed:@"inactiveWTabCloseHover"];
			else
				close = [NSImage imageNamed:@"inactiveWTabClose"];
		}
	}
	
	[left drawInRect:NSMakeRect(0, 0, 11, 24) fromRect:NSMakeRect(0, 0, 11, 24) operation:NSCompositeSourceOver fraction:1.0f];
	[right drawInRect:NSMakeRect(dirtyRect.size.width-11, 0, 11, 24) fromRect:NSMakeRect(0, 0, 11, 24) operation:NSCompositeSourceOver fraction:1.0f];
	[fill drawInRect:NSMakeRect(10, 0, dirtyRect.size.width-20, 24) fromRect:NSMakeRect(0, 0, 10, 24) operation:NSCompositeSourceOver fraction:1.0f];
	
	
	if( _mouseInside )
		[close drawInRect:NSMakeRect(10, 4, 12, 13) fromRect:NSMakeRect(0, 0, 12, 13) operation:NSCompositeSourceOver fraction:1.0f];
	
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	[style setAlignment:NSCenterTextAlignment];
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow setShadowColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.41]];
	
	NSColor *textColor = nil;
	if( [[self window] isMainWindow] )
	{
		textColor = [NSColor colorWithCalibratedWhite:0.2f alpha:1.0f];
	}
	else
	{
		textColor = [NSColor colorWithCalibratedWhite:0.4f alpha:1.0f];
	}
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName, shadow,NSShadowAttributeName, textColor,NSForegroundColorAttributeName, nil];
	
	if( ! _title )
		_title = [@"" retain];
	
	NSAttributedString *titleAttrStr = [[NSAttributedString alloc] initWithString:_title attributes:attributes];
	CGFloat height = [titleAttrStr size].height/2;
	NSRect stringRect = NSMakeRect(10, (dirtyRect.size.height/2)-height-2.0f, dirtyRect.size.width-20, 24-height);
	[titleAttrStr drawInRect:stringRect];
	[titleAttrStr release];
}


- (void)mouseEntered:(NSEvent *)theEvent
{
	_mouseInside = true;
	
	NSPoint actual = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
	
	if( actual.x > 7 && actual.x < 26 && actual.y > 251 && actual.y < 263 )
	{
		_mouseInsideClose = true;
		NSLog(@"InsideClose");
	}
	
	NSLog(@"Kanker: %lf %lf  ",actual.x,actual.y);
	[self setNeedsDisplay:true];
}

- (void)mouseExited:(NSEvent *)theEvent
{	
	NSPoint actual = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
	actual.y -= 246; // kinda random, but whatever
	if( actual.y < 0 )
		actual.y = 3;
	NSRect frame = [self frame];
	if( frame.origin.x < actual.x && frame.size.width > actual.x && frame.origin.y < actual.y && frame.size.height > actual.y )
	{
		_mouseInsideClose = false;
		_mouseInside = true;
	}
	else
	{
		_mouseInsideClose = false;
		_mouseInside = false;
	}
	
	NSLog(@"Kanker: %lf %lf  %lf %lf %lf %lf",actual.x,actual.y,frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
	
	[self setNeedsDisplay:true];
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];

	NSArray *trackingAreas = [self trackingAreas];
	NSUInteger i, cnt = [trackingAreas count];
	for(i=0;i<cnt;i++)
	{
		[self removeTrackingArea:[trackingAreas objectAtIndex:i]];
	}
	
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame] options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	[trackingArea release];
	
	trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(14, 4, 12, 13) options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	[trackingArea release];
}


- (void)mouseDown:(NSEvent *)theEvent
{
	_dragging = false;
	if( !_selected )
	{
		SFTabStripView *strip = (SFTabStripView *)[self superview];
		[strip selectTab:self];
	}
	
	_originalPoint	= [NSEvent mouseLocation];
	_originalRect	= [self frame];
	
	NSPoint actual = [[self window] convertScreenToBase:_originalPoint];
	
	if( actual.x > 10 && actual.x < 22 && actual.y > 251 && actual.y < 263 )
		_mouseDownInsideClose = true;
	else
		_mouseDownInsideClose = false;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if( !_selected )
		return;
	NSPoint newPoint = [NSEvent mouseLocation];
	CGFloat deltaX = _originalPoint.x - newPoint.x;
	
	if( ! _dragging )
	{
		if( deltaX < 10.0f && deltaX > -10.0f )
		{
			return;
		}
		else
		{
			_dragging = true;
		}
	}
	
	NSRect ownFrame = [self frame];
	ownFrame.origin.x -= deltaX;
	_originalPoint = [NSEvent mouseLocation];
	[self setFrame:ownFrame];
	
	SFTabStripView *tabStrip = (SFTabStripView *)[self superview];
	
	NSUInteger i, cnt = [tabStrip.tabs count];
	for(i=0;i<cnt;i++)
	{
		SFTabView *tabView = [tabStrip.tabs objectAtIndex:i];
		if( tabView == self )
			continue;
		
		NSRect frame = [tabView frame];
		
		// first determine on which side the other tab exists
		if( frame.origin.x <= ownFrame.origin.x )
		{
			if( (frame.origin.x+(frame.size.width/2)) >= ownFrame.origin.x )
			{
				[tabView setFrame:_originalRect];
				_originalRect = frame;
				NSUInteger idx = [tabStrip.tabs indexOfObject:self];
				[tabStrip.tabs exchangeObjectAtIndex:i withObjectAtIndex:idx];
				return;
			}
		}
		else if( frame.origin.x >= ownFrame.origin.x )
		{
			if( (frame.origin.x) <= (ownFrame.origin.x+(ownFrame.size.width/2)) )
			{
				[tabView setFrame:_originalRect];
				_originalRect = frame;
				NSUInteger idx = [tabStrip.tabs indexOfObject:self];
				[tabStrip.tabs exchangeObjectAtIndex:i withObjectAtIndex:idx];
				return;
			}
		}
	}
	return;
	
	for(SFTabView *tabView in tabStrip.tabs)
	{
		if( tabView == self )
			continue;
		
		NSRect frame = [tabView frame];
		
		// first determine on which side the other tab exists
		if( frame.origin.x <= ownFrame.origin.x )
		{
			if( (frame.origin.x+(frame.size.width/2)) >= ownFrame.origin.x )
			{
				[tabView setFrame:_originalRect];
				_originalRect = frame;
				return;
			}
		}
		else if( frame.origin.x >= ownFrame.origin.x )
		{
			if( (frame.origin.x) <= (ownFrame.origin.x+(ownFrame.size.width/2)) )
			{
				[tabView setFrame:_originalRect];
				_originalRect = frame;
				return;
			}
		}
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if( _mouseDownInsideClose )
	{
		NSPoint actual = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
		if( actual.x > 10 && actual.x < 22 && actual.y > 251 && actual.y < 263 )
		{
			if( [_target respondsToSelector:_selector] )
				[_target performSelector:_selector withObject:self];
		}
		_mouseDownInsideClose = false;
	}
	
	if( !_selected )
		return;
	[[self animator] setFrame:_originalRect];
}

@end
