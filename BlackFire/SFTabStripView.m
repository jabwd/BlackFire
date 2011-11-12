//
//  SFTabStripView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#define TAB_OVERLAP 17.0f
#define TAB_HEIGHT	24.0f

#import "SFTabStripView.h"
#import "SFTabView.h"
#import "NSViewAdditions.h"

@implementation SFTabStripView

@synthesize tabs = _tabs;

- (id)initWithFrame:(NSRect)frameRect
{
	if( (self = [super initWithFrame:frameRect]) )
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidResignMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidBecomeMainNotification object:nil];
		
		_tabs = [[NSMutableArray alloc] init];
		
		SFTabView *tabView = [[SFTabView alloc] initWithFrame:NSMakeRect(0, 0, 50, 24)];
		tabView.selected = true;
		[_tabs addObject:tabView];
		[tabView release];
		
		SFTabView *tabView2 = [[SFTabView alloc] initWithFrame:NSMakeRect(0, 0, 0, 24)];
		tabView2.selected = false;
		[_tabs addObject:tabView2];
		[tabView2 release];
		
		SFTabView *tabView3 = [[SFTabView alloc] initWithFrame:NSZeroRect];
		tabView3.selected = false;
		[_tabs addObject:tabView3];
		[tabView3 release];
		
		[self layoutTabs];
	}
	return self;
}

- (void)dealloc
{
	[_tabs release];
	_tabs = nil;
	[super dealloc];
}

- (void)update
{
	[self setNeedsDisplay:true];
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
	[newSelected orderOnTop];
	
	[self setNeedsDisplay:true];
}

- (void)layoutTabs
{
	CGFloat availableSpace = [self frame].size.width+(TAB_OVERLAP*([_tabs count]-1));
	CGFloat tabWidth = (CGFloat)availableSpace/((CGFloat)[_tabs count]);
	NSUInteger i, cnt = [_tabs count];
	SFTabView *selected = nil;
	for(i=0;i<cnt;i++)
	{
		NSRect viewFrame = NSMakeRect(tabWidth*i-(i*TAB_OVERLAP), 0, tabWidth, TAB_HEIGHT);
		SFTabView *tab = [_tabs objectAtIndex:i];
		if( tab.selected )
			selected = tab;
		[tab setFrame:viewFrame];
		
		[tab removeFromSuperview];
		[self addSubview:tab];
	}
	
	[selected orderOnTop];
}

@end
