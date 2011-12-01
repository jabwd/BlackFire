//
//  BFLoginViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFTabViewController.h"
#import "XFSession.h"

@interface BFLoginViewController : BFTabViewController
{
	NSButton			*_reconnectButton;
	
	NSTextField *_usernameField;
	NSTextField *_usernameLabel;
	NSTextField *_passwordField;
	NSTextField *_passwordLabel;
	
	NSProgressIndicator *_progressIndicator;
	NSTextField			*_connectionStatus;
}

@property (assign) IBOutlet NSButton *reconnectButton;

@property (assign) IBOutlet NSTextField *usernameField;
@property (assign) IBOutlet NSTextField *usernameLabel;
@property (assign) IBOutlet NSTextField *passwordField;
@property (assign) IBOutlet NSTextField *passwordLabel;

@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *connectionStatus;

- (IBAction)reconnect:(id)sender;

- (void)session:(XFSession *)session changedStatus:(XFSessionStatus)newStatus;
@end
