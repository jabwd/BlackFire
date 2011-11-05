//
//  ADAppDelegate.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XFSession.h"
#import "BFSetupWindowController.h"

@class BFSetupWindowController, BFAccount;

@interface ADAppDelegate : NSObject <NSApplicationDelegate, XFSessionDelegate, BFSetupWindowControllerDelegate>
{
	BFSetupWindowController *_setupWindowController;
	XFSession				*_session;
	BFAccount				*_account;
}

@property (readonly) XFSession *session;
@property (assign) IBOutlet NSWindow *window;

//----------------------------------------------------------------------------
// Xfire Session
- (void)connectionCheck;

@end
