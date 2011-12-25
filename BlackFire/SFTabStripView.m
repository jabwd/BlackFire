//
//  SFTabStripView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#define TAB_OVERLAP 10.0f
#define TAB_HEIGHT	24.0f
#define TAB_WIDTHMAX 160.0f

#import "SFTabStripView.h"
#import "SFTabView.h"
#import "NSViewAdditions.h"

@implementation SFTabStripView

@synthesize tabs		= _tabs;
@synthesize delegate	= _delegate;

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) )
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidResignMainNotification object:self.window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidBecomeMainNotification object:self.window];
		_tabs = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_tabs release];
	_tabs = nil;
	[super dealloc];
}

- (void)update
{
	[self setNeedsDisplay:true];
	[self layoutTabs];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
	[super resizeWithOldSuperviewSize:oldSize];
	[self layoutTabs];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSImage *image;
	if( [[self window] isMainWindow] )
	{
		image = [NSImage imageNamed:@"inactiveTabFill"];
	}
	else
	{
		image = [NSImage imageNamed:@"inactiveWTabFill"];
	}
	
	[image drawInRect:dirtyRect fromRect:NSMakeRect(0, 0, 0, 24.0) operation:NSCompositeSourceOver fraction:1.0f];
}

#pragma mark - Laying out the tabs

- (void)selectTab:(SFTabView *)newSelected
{
	for(SFTabView *tabView in _tabs)
	{
		if( tabView.selected )
			tabView.selected = false;
	}
	
	newSelected.selected = true;
	
	[self setNeedsDisplay:true];
	
	if( [_delegate respondsToSelector:@selector(didSelectNewTab:)] )
		[_delegate didSelectNewTab:newSelected];
	
	[self layoutTabs];
}

- (void)layoutTabs
{
	CGFloat availableSpace = [self frame].size.width+(TAB_OVERLAP*([_tabs count]-1));
	CGFloat tabWidth = (CGFloat)availableSpace/((CGFloat)[_tabs count]);
	NSUInteger i, cnt = [_tabs count];
	SFTabView *selected = nil;
	for(i=0;i<cnt;i++)
	{
		if( tabWidth > TAB_WIDTHMAX )
			tabWidth = TAB_WIDTHMAX;
		NSRect viewFrame = NSMakeRect(tabWidth*i-(i*TAB_OVERLAP), 0, tabWidth, TAB_HEIGHT);
		SFTabView *tab = [_tabs objectAtIndex:i];
		if( tab.selected )
			selected = tab;
		[tab setFrame:viewFrame];
		[tab updateTrackingAreas];
		
		if( ! selected )
		{
			[tab orderOnTop];
			tab.tabRightSide = false;
		}
		else if( tab != selected )
		{
			tab.tabRightSide = true;
		}
	}
	
	// reverse loop
	for(i=cnt;i>0;i--)
	{
		SFTabView *tab = [_tabs objectAtIndex:(i-1)]; // compensate for the 0 index
		if( tab.selected )
			break; // done here.
		
		[tab orderOnTop];
	}
	
	[selected orderOnTop];
}

#pragma mark - Managing tabs

- (void)addTabView:(SFTabView *)tabView
{
	[self addSubview:tabView];
	[_tabs addObject:tabView];
	[self layoutTabs];
}

- (void)removeTabView:(SFTabView *)tabView
{
	[tabView retain];
	[tabView removeFromSuperview];
	
	NSUInteger i,cnt = [_tabs count];
	for(i=0;i<cnt;i++)
	{
		if( [[_tabs objectAtIndex:i] tag] == tabView.tag )
		{
			[_tabs removeObjectAtIndex:i];
			break;
		}
	}

	
	if( tabView.selected && [_tabs count] > 0  )
	{
		[self selectTab:[_tabs objectAtIndex:0]];
	}
	
	[self layoutTabs];
	[tabView release];
}

- (SFTabView *)tabViewForTag:(NSUInteger)tag
{
	for(SFTabView *view in _tabs)
	{
		if( view.tag == tag )
			return view;
	}
	return nil;
}

- (void)aTabIsDragging
{
	for(SFTabView *view in _tabs)
	{
		view.tabDragAction = true;
	}
}

- (void)tabDoneDragging
{	
	for(SFTabView *view in _tabs)
	{
		view.tabDragAction = false;
	}
	[self layoutTabs];
}

@end
