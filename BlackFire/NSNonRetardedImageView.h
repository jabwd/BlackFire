//
//  NSNonRetardedImageView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/24/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSNonRetardedImageView : NSView
{
	NSImage *_image;
	NSColor *_borderColor;
}

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSColor *borderColor;

//-------------------------------------------------------------------------
// Image processing

- (NSColor *)proposedBorderColorForImage:(NSImage *)image;

@end
