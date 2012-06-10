//
//  BFTabViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFTabViewController.h"

@implementation BFTabViewController

@synthesize view		= _view;
@synthesize delegate	= _delegate;
@synthesize infoViewController = _infoViewController;

- (void)becomeMain
{
	
}

- (void)resignMain
{
	
}

- (void)dealloc{
	[_infoViewController release];
	_infoViewController = nil;
	[super dealloc];
}

@end
