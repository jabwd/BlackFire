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
	BFApplicationModeOffline = 1,
	BFApplicationModeLoggingIn = 2,
	BFApplicationModeOnline = 3,
	BFApplicationModeGames = 4,
	BFApplicationModeServers = 5
} BFApplicationMode;

@class BFLoginViewController;

@interface ADAppDelegate : NSObject <NSApplicationDelegate, XFSessionDelegate, BFSetupWindowControllerDelegate>
{
	BFSetupWindowController *_setupWindowController;
	XFSession				*_session;
	BFAccount				*_account;
	
	NSView *_mainView;
	
	BFLoginViewController	*_loginViewController;
	
	BFApplicationMode		_currentMode;
}

@property (readonly) XFSession *session;
@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSView *mainView;

//----------------------------------------------------------------------------
// Managing the main window

- (void)changeToMode:(BFApplicationMode)newMode;
- (void)changeMainView:(NSView *)newView;

//----------------------------------------------------------------------------
// Xfire Session
- (void)connectionCheck;

@end
