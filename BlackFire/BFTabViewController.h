//
//  BFTabViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ADAppDelegate;

@interface BFTabViewController : NSObject
{
	NSView *_view;
	
	ADAppDelegate *_delegate;
}

@property (assign) IBOutlet NSView *view;
@property (assign) ADAppDelegate *delegate;

- (void)becomeMain;

- (void)resignMain;

@end
