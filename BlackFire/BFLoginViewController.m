//
//  BFLoginViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFLoginViewController.h"
#import "ADAppDelegate.h"
#import "BFAccount.h"

@implementation BFLoginViewController




- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"LoginView" owner:self];
		NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountName"];
		if( [username length] > 0 )
		{
			BFAccount *account = [[BFAccount alloc] initWithUsername:username];
			[_usernameField setStringValue:username];
			NSString *password = account.password;
			if( ! password )
				password = @"";
			[_passwordField setStringValue:account.password];
		}
	}
	return self;
}

- (IBAction)reconnect:(id)sender
{
	if( [_usernameField isHidden] )
	{
		[self.delegate disconnect:nil];
	}
	else if( [[_usernameField stringValue] length] > 0 && [[_passwordField stringValue] length] > 0 )
	{
		BFAccount *account = [[BFAccount alloc] initWithUsername:[_usernameField stringValue]];
		[account setPassword:[_passwordField stringValue]];
		[account save];
		[[NSUserDefaults standardUserDefaults] setObject:account.username forKey:@"accountName"];
		[self.delegate connectionCheck];
	}
}

- (void)session:(XFSession *)session changedStatus:(XFSessionStatus)newStatus
{
	if( newStatus == XFSessionStatusConnecting )
	{
		[_reconnectButton setTitle:@"Cancel"];
		[_reconnectButton setHidden:false];
		
		[_progressIndicator startAnimation:nil];
		[_progressIndicator setHidden:false];
		
		[_connectionStatus setStringValue:@"Connecting…"];
		[_connectionStatus setHidden:false];
		
		[_usernameField setHidden:true];
		[_usernameLabel setHidden:true];
		[_passwordField setHidden:true];
		[_passwordLabel setHidden:true];
	}
	else if( newStatus == XFSessionStatusOnline )
	{
		[_reconnectButton setHidden:true];
		
		[_progressIndicator setHidden:true];
		[_progressIndicator stopAnimation:nil];
		
		[_connectionStatus setStringValue:@"Waiting…"];
		[_connectionStatus setHidden:false];
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		[_reconnectButton setTitle:@"Connect"];
		[_reconnectButton setHidden:false];
		
		[_progressIndicator stopAnimation:nil];
		[_progressIndicator setHidden:true];
		
		[_connectionStatus setStringValue:@"Offline"];
		[_connectionStatus setHidden:false];
		
		[_usernameField setHidden:false];
		[_usernameLabel setHidden:false];
		[_passwordField setHidden:false];
		[_passwordLabel setHidden:false];
	}
}
@end
