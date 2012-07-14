//
//  BFSidebarView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/7/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFSidebarView.h"

@implementation BFSidebarView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    /*NSImage *image = [NSImage imageNamed:@"bg_pattern"];
	
	NSColor *pattern = [NSColor colorWithPatternImage:image];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor blackColor]];
	[shadow setShadowBlurRadius:5.0f];
	[shadow setShadowOffset:NSMakeSize(5.0f, 0.0f)];
	
	[pattern set];
	NSRectFill(dirtyRect);
	
	[[NSColor colorWithCalibratedWhite:0.2f alpha:1.0f] set];
	NSRectFill(NSMakeRect(dirtyRect.origin.x, 0, dirtyRect.size.width, 1));
	[shadow set];
	NSRectFill(NSMakeRect(0, 0, 1, dirtyRect.size.height));
	
	// cleanup
	[shadow release];*/
}

@end
