//
//  BFTabViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BFTabViewController : NSObject
{
	NSView *_view;
}

@property (assign) IBOutlet NSView *view;

- (void)becomeMain;

- (void)resignMain;

@end
