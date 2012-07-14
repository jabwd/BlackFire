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

@property (unsafe_unretained) IBOutlet NSButton *reconnectButton;
@property (unsafe_unretained) IBOutlet NSTextField *usernameField;
@property (unsafe_unretained) IBOutlet NSTextField *usernameLabel;
@property (unsafe_unretained) IBOutlet NSTextField *passwordField;
@property (unsafe_unretained) IBOutlet NSTextField *passwordLabel;
@property (unsafe_unretained) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSTextField *connectionStatus;

- (IBAction)reconnect:(id)sender;

- (void)session:(XFSession *)session changedStatus:(XFSessionStatus)newStatus;
@end
