//
//  BFSetupWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFSetupWindowController.h"
#import "BFKeychainManager.h"

@implementation BFSetupWindowController

@synthesize delegate = _delegate;
@synthesize window = _window;

@synthesize nextButton		= _nextButton;
@synthesize previousButton	= _previousButton;

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

@synthesize mainView		= _mainView;
@synthesize accountInfoView = _accountInfoView;
@synthesize settingsView	= _settingsView;
@synthesize finishedView	= _finishedView;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:windowNibName owner:self];
		[_window makeKeyAndOrderFront:self];
		[_window setDelegate:self];
		[_window center];
		_currentMode = 0;
		_delegate = nil;
	}
	return self;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[_delegate setupWindowClosed];
}

- (IBAction)next:(id)sender
{
	switch(_currentMode)
	{
		case 0:
		{
			NSArray *subviews = [[_mainView contentView] subviews];
			for(NSView *subview in subviews)
			{
				[subview removeFromSuperview];
			}
			
			[[_mainView contentView] addSubview:_accountInfoView];
			_currentMode = 1;
			//[_accountInfoView setFrame:[_mainView bounds]];
		}
			break;
			
		case 1:
		{
			if( [[_usernameField stringValue] length] < 1 || [[_passwordField stringValue] length] < 1 )
				return;
			
			
			// save the login credentials
			BFKeychainManager *manager = [BFKeychainManager defaultManager];
			if( [[manager passwordForServiceName:@"BlackFire" accountName:[_usernameField stringValue]] length] > 0 )
			{
				[manager replacePassword:[_passwordField stringValue] serviceName:@"BlackFire" accountName:[_usernameField stringValue]];
			}
			else
			{
				[manager addPassword:[_passwordField stringValue] serviceName:@"BlackFire" accountName:[_usernameField stringValue]];
			}
			
			NSArray *accounts = [[NSArray alloc] initWithObjects:[_usernameField stringValue], nil];
			[[NSUserDefaults standardUserDefaults] setObject:accounts forKey:@"accounts"];
			[accounts release];
			
			NSArray *subviews = [[_mainView contentView] subviews];
			for(NSView *subview in subviews)
			{
				[subview removeFromSuperview];
			}
			
			[[_mainView contentView] addSubview:_finishedView];
			_currentMode++;
			[_nextButton setTitle:@"Finish"];
		}
			break;
			
		case 2:
		{
			// close this window
			[_window close];
			[_delegate setupWindowClosed];
		}
			break;
	}
}

- (IBAction)previous:(id)sender
{
	
}

- (IBAction)newAccount:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.xfire.com/register/"]];
}

@end