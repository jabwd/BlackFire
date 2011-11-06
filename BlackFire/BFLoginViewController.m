//
//  BFLoginViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFLoginViewController.h"
#import "ADAppDelegate.h"

@implementation BFLoginViewController

@synthesize reconnectButton		= _reconnectButton;
@synthesize otherAccountButton	= _otherAccountButton;
@synthesize progressIndicator	= _progressIndicator;
@synthesize connectionStatus	= _connectionStatus;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"LoginView" owner:self];
	}
	return self;
}

- (IBAction)reconnect:(id)sender
{
	if( _delegate.session.status == XFSessionStatusOffline )
	{
		[_delegate connectionCheck];
	}
	else if( _delegate.session.status == XFSessionStatusConnecting )
	{
		[_delegate.session disconnect];
	}
}

- (IBAction)account:(id)sender
{
	// show other account window
}

- (void)session:(XFSession *)session changedStatus:(XFSessionStatus)newStatus
{
	if( newStatus == XFSessionStatusConnecting )
	{
		[_otherAccountButton setHidden:true];
		
		[_reconnectButton setTitle:@"Cancel"];
		[_reconnectButton setHidden:false];
		
		[_progressIndicator startAnimation:nil];
		[_progressIndicator setHidden:false];
		
		[_connectionStatus setStringValue:@"Connecting…"];
		[_connectionStatus setHidden:false];
	}
	else if( newStatus == XFSessionStatusOnline )
	{
		[_reconnectButton setHidden:true];
		[_otherAccountButton setHidden:true];
		
		[_progressIndicator setHidden:true];
		[_progressIndicator stopAnimation:nil];
		
		[_connectionStatus setStringValue:@"Waiting…"];
		[_connectionStatus setHidden:false];
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		[_reconnectButton setTitle:@"Reconnect"];
		[_otherAccountButton setTitle:@"Account…"];
		
		[_otherAccountButton setHidden:false];
		[_reconnectButton setHidden:false];
		
		[_progressIndicator stopAnimation:nil];
		[_progressIndicator setHidden:true];
		
		[_connectionStatus setStringValue:@"Offline"];
		[_connectionStatus setHidden:false];
	}
}
@end
