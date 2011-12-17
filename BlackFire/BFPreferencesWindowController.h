//
//  BFPreferencesWindow.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/14/09.
//  Copyright 2009 Excurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	generalMode = 1
} BFPrefsMode;

@interface BFPreferencesWindowController : NSWindowController <NSToolbarDelegate> 
{
}

@property (assign) IBOutlet NSView						*generalView;
@property (assign) IBOutlet NSToolbarItem				*generalItem;
@property (assign) IBOutlet NSUserDefaultsController	*defaultsController;

//-------------------------------------------------------------------------------------------
// Mode switching
- (void)removeAllSubviews:(NSView *)aView;
- (void)changeToMode:(BFPrefsMode)aMode;

- (IBAction)generalMode:(id)sender;

@end
