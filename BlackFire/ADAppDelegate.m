//
//  ADAppDelegate.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ADAppDelegate.h"
#import "XFSession.h"

@implementation ADAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	XFSession *session = [[XFSession alloc] initWithDelegate:self];
	
	[session connect];
}


#pragma mark - Session delegate

- (void)session:(XFSession *)session loginFailed:(XFLoginError)reason
{
	
}

- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus
{
	
}

@end
