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
}

@property (nonatomic, retain) NSImage *image;
@end
