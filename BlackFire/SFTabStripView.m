//
//  SFTabStripView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#define TAB_OVERLAP 17.0f
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidResignMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:NSWindowDidBecomeMainNotification object:nil];
		
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
		
		[tab removeFromSuperview];
		[self addSubview:tab];
		
		if( ! selected )
		{
			[tab orderOnTop];
		}
		/*else
		{
			// we passed the selected tab so now we need to do it a bit more advanced.
			if( (i+1) < cnt )
			{
				SFTabView *nextTab = [_tabs objectAtIndex:(i+1)];
				[nextTab orderOnTopOfView:tab];
			}
		}*/ // done in the second loop
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
		[self layoutTabs];
	}
	
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

@end
