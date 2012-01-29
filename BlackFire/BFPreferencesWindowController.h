//
//  BFPreferencesWindow.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/14/09.
//  Copyright 2009 Excurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BFPreferencesWindowController : NSWindowController <NSToolbarDelegate> 
{
	NSMutableArray *_soundsets;
}

@property (assign) IBOutlet NSView	*generalView;
@property (assign) IBOutlet NSView	*notificationsView;
@property (assign) IBOutlet NSView	*chatView;
@property (assign) IBOutlet NSView  *gamesView;

@property (assign) IBOutlet NSToolbarItem				*generalItem;

@property (assign) IBOutlet NSPopUpButton *soundsetDropDown;

//-------------------------------------------------------------------------------------------
// Mode switching
- (void)removeAllSubviewsAndReplaceWithView:(NSView *)aView;

- (IBAction)generalMode:(id)sender;
- (IBAction)notificationsMode:(id)sender;
- (IBAction)chatMode:(id)sender;
- (IBAction)gamesMode:(id)sender;



//-------------------------------------------------------------------------------------------
// Controlling preferences

- (IBAction)updateIdleTimer:(id)sender;
- (IBAction)updateVolume:(id)sender;
- (IBAction)moreSoundsets:(id)sender;

@end
