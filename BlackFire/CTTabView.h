//
//  CTTabView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTTabView : NSView
{
	NSPoint hoverPoint_;  // Current location of hover in view coords.
	
	NSPoint _dragOrigin;
	NSRect _originalFrame;
	NSPoint _hitOrigin;
}


// the bezier path for the tabview
- (NSBezierPath *)bezierPathForRect:(NSRect)rect;
@end
