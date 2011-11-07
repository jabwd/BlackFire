//
//  BFChatWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFChatWindowController.h"
#import "CTTabController.h"

@implementation BFChatWindowController

@synthesize tabController = _tabController;

@synthesize window = _window;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"BFChatWindow" owner:self];
		[_window setContentBorderThickness:34.0 forEdge:NSMinYEdge];
		[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
		[_window makeKeyAndOrderFront:self];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark - NSSplitviewDelegate
/*
-(NSView* )resizeView 
{
	// TODO: return the view which contains the resize control
}

-(NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
	return [[self resizeView] convertRect:[[self resizeView] bounds] toView:splitView]; 
}*/

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 65.0f;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return 10000.0f;
}

@end
