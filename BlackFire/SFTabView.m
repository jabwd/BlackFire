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
{	
	NSRect _originalRect;
	NSRect _latestRect;
	NSPoint _originalPoint;
	
	BOOL _mouseInside;
	BOOL _dragging;
	BOOL _mouseInsideClose;
	BOOL _mouseDownInsideClose;
}

- (id)initWithFrame:(NSRect)frame
{
    if( (self = [super initWithFrame:frame]) )
	{
		_title = nil;
		
		_tabDragAction = false;
		_mouseInside = false;
		
		
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(8, 0, frame.size.width-8, frame.size.height) options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
		[self addTrackingArea:trackingArea];
		
		/*trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(10, 4, 12, 13) options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
		[self addTrackingArea:trackingArea];
		[trackingArea release];*/
	}
    return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return true;
}

- (BOOL)mouseDownCanMoveWindow
{
	if( [_tabStrip.tabs count] > 1 )
		return false;
	return true;
}

- (void)drawRect:(NSRect)useless
{
	NSRect dirtyRect = [self bounds];
	NSImage *left,*right,*fill,*close;
	
	if( self.selected )
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
	
	// improves the way the tabs are drawn on the screen
	if( _tabDragAction || self.selected )
	{
		[left drawInRect:NSMakeRect(0, 0, 11, 24) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
		[right drawInRect:NSMakeRect(dirtyRect.size.width-11, 0, 11, 24) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
	}
	else
	{
		if( _tabRightSide )
		{
			[right drawInRect:NSMakeRect(dirtyRect.size.width-11, 0, 11, 24) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
		}
		else
		{
			[left drawInRect:NSMakeRect(0, 0, 11, 24) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
		}
	}
	
	
	// optimizes the drawing. the tabstrip already has this fill.
	if( self.selected )
	{
		[[NSGraphicsContext currentContext] saveGraphicsState];
		[[NSGraphicsContext currentContext] setPatternPhase:NSMakePoint(0, [[self superview] frame].origin.y)];
		[[NSColor colorWithPatternImage:fill] set];
		NSRectFill(NSMakeRect(10, 0, dirtyRect.size.width-20, 24));
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	}
	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	[style setAlignment:NSCenterTextAlignment];
	
	NSShadow *shadow = [[NSShadow alloc] init];
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
	
	NSDictionary *attributes = @{NSParagraphStyleAttributeName: style, NSShadowAttributeName: shadow, NSForegroundColorAttributeName: textColor};
	
	if( ! _title )
		_title = @"";
	
	NSAttributedString *titleAttrStr = [[NSAttributedString alloc] initWithString:_title attributes:attributes];
	/*CGFloat height = [titleAttrStr size].height/2;
	CGFloat baseX = 26;
	CGFloat width = [titleAttrStr size].width;
	if( (dirtyRect.size.width-40) < width )
		width = dirtyRect.size.width-40;
	else
	{
		baseX = (dirtyRect.size.width/2)-(width/2);
	}
	// safeguard
	if( baseX < 26 )
		baseX = 26;
	NSRect stringRect = NSMakeRect(baseX, (dirtyRect.size.height/2)-height-2.0f, width, 24-height);*/
	CGFloat height = [titleAttrStr size].height/2;
	NSRect stringRect = NSMakeRect(dirtyRect.origin.x+26, (dirtyRect.size.height/2)-height-2.0f, dirtyRect.size.width-52, 24-height);
	[titleAttrStr drawInRect:stringRect];
	
	// draw the close button on top of everything
	if( _mouseInside )
	{
		[close drawInRect:NSMakeRect(10, 4, 12, 13) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
	}
	else if( _image )
		[_image drawInRect:NSMakeRect(10, 4, 14, 13) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
	
	if( _missedMessages > 0 )
	{
		NSDictionary *newAttr = [[NSDictionary alloc] initWithObjectsAndKeys:[NSColor whiteColor],NSForegroundColorAttributeName,style,NSParagraphStyleAttributeName, nil];
		NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu",_missedMessages] attributes:newAttr];
		
		// draw some sort of bezel around it
		NSRect stringRect = NSMakeRect(dirtyRect.size.width-20-[countString size].width, 4, [countString size].width, 13);
		NSBezierPath *bezelPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(stringRect.origin.x, stringRect.origin.y, stringRect.size.width+10, stringRect.size.height+2) xRadius:8.0f yRadius:7.0f];
		if( [[self window] isMainWindow] )
			[[NSColor darkGrayColor] set];
		else
			[[NSColor colorWithCalibratedWhite:0.6f alpha:1.0f] set];
		[bezelPath fill];
		
		[countString drawInRect:NSMakeRect(dirtyRect.size.width-15-[countString size].width, 6, [countString size].width, 13)];
	}
}


- (void)mouseEntered:(NSEvent *)theEvent
{
	_mouseInside = true;
	
	/*NSPoint actual = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
	
	if( actual.x > 7 && actual.x < 26 && actual.y > 251 && actual.y < 263 )
	{
		_mouseInsideClose = true;
		NSLog(@"InsideClose");
	}*/
	
	//NSLog(@"Kanker: %lf %lf  ",actual.x,actual.y);
	[self setNeedsDisplay:true];
}

- (void)mouseExited:(NSEvent *)theEvent
{	
	/*NSPoint actual = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
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
	*/
	_mouseInside = false;
	//NSLog(@"Kanker: %lf %lf  %lf %lf %lf %lf",actual.x,actual.y,frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
	
	[self setNeedsDisplay:true];
}

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];

	NSArray *trackingAreas = [self trackingAreas];
	NSUInteger i, cnt = [trackingAreas count];
	for(i=0;i<cnt;i++)
	{
		[self removeTrackingArea:trackingAreas[i]];
	}
	NSRect frame = [self frame];
	
	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(8, 0, frame.size.width-8, frame.size.height) options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	
	/*trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(14, 4, 12, 13) options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];
	[trackingArea release];*/
}

- (void)mouseDown:(NSEvent *)theEvent
{
	_dragging = false;
	
	_originalPoint	= [NSEvent mouseLocation];
	_originalRect	= [self frame];
	
	NSPoint new = [[self window] convertScreenToBase:_originalPoint];
	NSPoint actual = [self convertPoint:new fromView:[[[self window] contentView] superview]];
	
	if( actual.x > 10 && actual.x < 22 && actual.y > 3 && actual.y < 19 )
	{
		_mouseDownInsideClose = true;
		_mouseInsideClose = true;
		[self setNeedsDisplay:true];
		return;
	}
	else
	{
		if( !_selected )
		{
			SFTabStripView *strip = (SFTabStripView *)[self superview];
			[strip selectTab:self];
		}
		_mouseInsideClose = false;
		_mouseDownInsideClose = false;
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	// for some reason mouseDragged is called when vigorously dragging with the window around your screen,
	// in order not to make the tab feel retarded: do this.
	if( ! _mouseInside || [_tabStrip.tabs count] < 2 )
	{
		[super mouseDragged:theEvent];
		return;
	}

	NSPoint newPoint = [NSEvent mouseLocation];
	CGFloat deltaX = _originalPoint.x - newPoint.x;
	SFTabStripView *tabStrip = (SFTabStripView *)[self superview];
	if( ![tabStrip isKindOfClass:[SFTabStripView class]] )
	{
		NSLog(@"*** Superview != SFTabStripView");
		abort();
	}
	
	if( ! _dragging )
	{
		if( deltaX < 10.0f && deltaX > -10.0f )
		{
			return;
		}
		else
		{
			_dragging = true;
			
			// this informs other tabs that they have to draw a complete tab
			// we are lazy when nothing is happening and only partially drawing tabs
			// as some part is hidden under another tab anyways
			[tabStrip aTabIsDragging];
		}
	}
	
	NSRect ownFrame = [self frame];
	ownFrame.origin.x -= deltaX;
	_originalPoint = [NSEvent mouseLocation];
	[self setFrame:ownFrame];
	
	NSUInteger i, cnt = [tabStrip.tabs count];
	for(i=0;i<cnt;i++)
	{
		SFTabView *tabView = (tabStrip.tabs)[i];
		if( tabView == self )
			continue;
		
		NSRect frame = [tabView frame];
		if( tabView.animating )
		{
			frame = tabView.proposedLocation;
		}
		
		// determine on which side ( relative to this tab ) the tab under this one is
		// then act accordingly.
		if( frame.origin.x <= ownFrame.origin.x )
		{
			if( (frame.origin.x+(frame.size.width/2)) >= ownFrame.origin.x )
			{
				//[tabView setFrame:_originalRect];
				[tabView moveToFrame:_originalRect];
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
				//[tabView setFrame:_originalRect];
				[tabView moveToFrame:_originalRect];
				_originalRect = frame;
				NSUInteger idx = [tabStrip.tabs indexOfObject:self];
				[tabStrip.tabs exchangeObjectAtIndex:i withObjectAtIndex:idx];
				return;
			}
		}
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if( _mouseDownInsideClose )
	{
		NSPoint new = [[self window] convertScreenToBase:_originalPoint];
		NSPoint actual = [self convertPoint:new fromView:[[[self window] contentView] superview]];
		if( actual.x > 10 && actual.x < 22 && actual.y > 3 && actual.y < 19 )
		{
			/*[NSAnimationContext beginGrouping];
			[[NSAnimationContext currentContext] setDuration:0.100f];
			[[NSAnimationContext currentContext] setCompletionHandler:^{
				if( [_target respondsToSelector:_selector] )
					[_target performSelector:_selector withObject:self];
			}];
			NSRect frame = self.frame;
			[[self animator] setFrame:NSMakeRect(frame.origin.x, frame.origin.y, 30, frame.size.height)];
			[NSAnimationContext endGrouping];*/ // enable this later on
			if( [_target respondsToSelector:_selector] )
				[_target performSelector:_selector withObject:self];
			
		}
		_mouseInsideClose = false;
		_mouseDownInsideClose = false;
	}
	
	if( _dragging )
	{
		SFTabStripView *tabStrip = (SFTabStripView *)[self superview];
		[tabStrip tabDoneDragging];
	}
	
	if( !_selected )
		return;
	//[[self animator] setFrame:_originalRect];
	[self setFrame:_originalRect];
	SFTabStripView *view = (SFTabStripView *)[self superview];
	[view layoutTabs];
}

- (void)moveToFrame:(NSRect)newFrame
{
	if( _animating )
	{
		_latestRect = newFrame;
		// will be handled later on.
		return;
	}
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:.125f];
	_animating = true;
	_latestRect = NSZeroRect;
	_proposedLocation = newFrame;
	[[self animator] setFrame:newFrame];
	[self performSelector:@selector(animationCleanup) withObject:nil afterDelay:.125f];
	[NSAnimationContext endGrouping];

}

- (void)animationCleanup
{
	_animating = false;
	if( _latestRect.origin.x != NSZeroRect.origin.x )
	{
		//[self moveToFrame:_latestRect];
	}
	[self setNeedsDisplay:true];
}

@end
