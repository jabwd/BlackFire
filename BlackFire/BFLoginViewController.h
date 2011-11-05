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
	NSButton			*_otherAccountButton;
	
	NSProgressIndicator *_progressIndicator;
	NSTextField			*_connectionStatus;
}

@property (assign) IBOutlet NSButton *reconnectButton;
@property (assign) IBOutlet NSButton *otherAccountButton;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *connectionStatus;

- (IBAction)reconnect:(id)sender;
- (IBAction)account:(id)sender;

- (void)session:(XFSession *)session changedStatus:(XFSessionStatus)newStatus;
@end
