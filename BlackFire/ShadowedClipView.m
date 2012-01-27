//
//  ShadowedClipView.m
//  BlackFire
//
//  Created by Antwan van Houdt on 1/25/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "ShadowedClipView.h"

#define SHADOW_HEIGHT 10.0f

@implementation ShadowedClipView

- (void)drawRect:(NSRect)dirtyRect
{
    
    // call super
    
    [super drawRect:dirtyRect];
	
	NSLog(@"Test!");
	
	[[NSColor blackColor] set];
	NSRectFill(dirtyRect);
    
    // work our the rects
    
    NSRect rect = [self documentVisibleRect];
    rect.size.height = [[self documentView] frame].size.height;
    
    [NSGraphicsContext saveGraphicsState];
    
    // set up our gradient
    
    NSGradient * grad = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:( 0.0 / 255.0 )
                                                                                        green:( 0.0 / 255.0 )
                                                                                         blue:( 0.0 / 255.0 )
                                                                                        alpha:.2]
                                                      endingColor:[NSColor clearColor]];
    
    // draw the background / any custom things, so the background and anything else
	
    [self drawBackground];
    
    
    if( [self visibleRect].origin.y < 0 )
    {
        
        // draw top static
        
        [grad drawInRect:NSMakeRect( 0.0, [self visibleRect].origin.y, [self bounds].size.width, SHADOW_HEIGHT )
                   angle:90.0];
        
        // non static top
        
        [grad drawInRect:NSMakeRect( 0.0, -SHADOW_HEIGHT, [self bounds].size.width, SHADOW_HEIGHT )
                   angle:270.0];
        
    }
    
    if( ( rect.size.height - rect.origin.y ) < [self visibleRect].size.height )
    {
        
        // draw bottom static
        
        [grad drawInRect:NSMakeRect( 0.0, ( [self visibleRect].size.height + [self visibleRect].origin.y ) - SHADOW_HEIGHT, [self bounds].size.width, SHADOW_HEIGHT )
                   angle:270.0];
        
        // bottom non static
        
        [grad drawInRect:NSMakeRect( 0.0, rect.size.height, [self bounds].size.width, SHADOW_HEIGHT )
                   angle:90.0];
        
    }
    
    // release the gradient
    
    [grad release];
    
    [NSGraphicsContext restoreGraphicsState];
    
}

- (void)drawBackground
{
    
    // just draw white
    
    [[NSColor whiteColor] set];
    NSRectFill( [self bounds] );
    
}

@end