//
//  SFTabView.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/7/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SFTabView : NSView
{
	NSString *_title;
	
	NSRect _originalRect;
	NSPoint _originalPoint;
	
	BOOL _selected;
}

@property (nonatomic, retain) NSString *title;

@property (assign) BOOL selected;
@end
