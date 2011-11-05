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

#import "BFLoginViewController.h"

@implementation ADAppDelegate

@synthesize window			= _window;
@synthesize session			= _session;
@synthesize mainView		= _mainView;

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

- (void)awakeFromNib
{
	[self changeToMode:BFApplicationModeOffline];
	[_window setContentBorderThickness:30.0 forEdge:NSMinYEdge];
	[_window setAutorecalculatesContentBorderThickness:false forEdge:NSMinYEdge];
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

- (void)changeToMode:(BFApplicationMode)newMode
{
	// computer says no.
	if( _currentMode == newMode )
		return;
	
	switch(newMode)
	{
		case BFApplicationModeOffline:
		{
			if( ! _loginViewController )
			{
				_loginViewController = [[BFLoginViewController alloc] init];
			}
			[_loginViewController session:_session changedStatus:XFSessionStatusOffline];
			
			[self changeMainView:_loginViewController.view];
		}
			break;
			
		case BFApplicationModeLoggingIn:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusConnecting];
		}
			break;
			
		case BFApplicationModeOnline:
		{
			[_loginViewController session:_session changedStatus:XFSessionStatusOnline];
		}
			break;
			
		case BFApplicationModeGames:
		{
			
		}
			break;
			
		case BFApplicationModeServers:
		{
			
		}
			break;
			
		default:
		{
			NSLog(@"Cannot switch to unknown BFApplication mode");
		}
			break;
	}
	
	_currentMode = newMode;
}

- (void)changeMainView:(NSView *)newView
{
	NSArray *subviews = [_mainView subviews];
	for(NSView *view in subviews)
	{
		[view removeFromSuperview];
	}
	
	[_mainView addSubview:newView];
	[newView setFrame:[_mainView bounds]];
}


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
		[self changeToMode:BFApplicationModeOnline];
	}
	else if( newStatus == XFSessionStatusConnecting )
	{
		[self changeToMode:BFApplicationModeLoggingIn];
	}
	else if( newStatus == XFSessionStatusOffline )
	{
		[self changeToMode:BFApplicationModeOffline];
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
