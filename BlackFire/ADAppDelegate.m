//
//  ADAppDelegate.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "ADAppDelegate.h"
#import "XFSession.h"

#import "BFAccount.h"
#import "BFSetupWindowController.h"

@implementation ADAppDelegate

@synthesize window = _window;
@synthesize session = _session;

- (void)dealloc
{
	[_setupWindowController release];
	_setupWindowController = nil;
	[_session disconnect];
	[_session release];
	_session = nil;
	[_account release];
	_account = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"finishedSetup"] )
	{
		_setupWindowController = [[BFSetupWindowController alloc] initWithWindowNibName:@"BFSetupWindow"];
		_setupWindowController.delegate = self;
	}
	else
	{
		NSArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
		if( [accounts count] > 0 )
		{
			[_account release];
			_account = [[BFAccount alloc] initWithUsername:[accounts objectAtIndex:0]];
			[self connectionCheck];
		}
		else
		{
			_setupWindowController = [[BFSetupWindowController alloc] initWithWindowNibName:@"BFSetupWindow"];
			_setupWindowController.delegate = self;
		}
	}
}

#pragma mark - Setup window

- (void)setupWindowClosed
{
	[_setupWindowController release];
	_setupWindowController = nil;
	
	[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"finishedSetup"];
	
	NSArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
	if( [accounts count] > 0 )
	{
		[_account release];
		_account = [[BFAccount alloc] initWithUsername:[accounts objectAtIndex:0]];
	}
	
	[self connectionCheck];
}

#pragma mark - Managing the main window


#pragma mark - Xfire Session

- (void)connectionCheck
{
	if( !_session || _session.status == XFSessionStatusOffline )
	{
		_session = [[XFSession alloc] initWithDelegate:self];
		[_session connect];
	}
}

- (void)session:(XFSession *)session loginFailed:(XFLoginError)reason
{
	
}

- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus
{
	if( newStatus == XFSessionStatusOnline )
	{
		NSLog(@"The session is now online.");
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		NSLog(@"The session is now offline.");
		[_session release];
		_session = nil;
	}
}

- (NSString *)username
{
	return _account.username;
}

- (NSString *)password
{
	return _account.password;
}

@end
