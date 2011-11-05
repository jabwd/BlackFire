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

typedef enum
{
	BFApplicationModeOffline = 0,
	BFApplicationModeLoggingIn,
	BFApplicationModeOnline,
	BFApplicationModeGames,
	BFApplicationModeServers
} BFApplicationMode;

@interface ADAppDelegate : NSObject <NSApplicationDelegate, XFSessionDelegate, BFSetupWindowControllerDelegate>
{
	BFSetupWindowController *_setupWindowController;
	XFSession				*_session;
	BFAccount				*_account;
	
	NSView					*_loginView;
	
	BFApplicationMode		_currentMode;
}

@property (readonly) XFSession *session;
@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSView *loginView;
@property (assign) IBOutlet NSView *friendsView;

//----------------------------------------------------------------------------
// Managing the main window

- (void)changeToMode:(BFApplicationMode)newMode;

//----------------------------------------------------------------------------
// Xfire Session
- (void)connectionCheck;

@end
