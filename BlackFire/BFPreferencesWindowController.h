//
//  BFPreferencesWindow.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/14/09.
//  Copyright 2009 Excurion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BFPreferencesWindowController : NSWindowController <NSToolbarDelegate> 

@property (unsafe_unretained) IBOutlet NSView	*generalView;
@property (unsafe_unretained) IBOutlet NSView	*notificationsView;
@property (unsafe_unretained) IBOutlet NSView	*chatView;
@property (unsafe_unretained) IBOutlet NSView  *gamesView;

@property (unsafe_unretained) IBOutlet NSToolbarItem				*generalItem;

@property (unsafe_unretained) IBOutlet NSPopUpButton *soundsetDropDown;



@property (unsafe_unretained) IBOutlet NSTextField *gamesVersionField;

//-------------------------------------------------------------------------------------------
// Mode switching
- (void)removeAllSubviewsAndReplaceWithView:(NSView *)aView;

- (IBAction)generalMode:(id)sender;
- (IBAction)notificationsMode:(id)sender;
- (IBAction)chatMode:(id)sender;
- (IBAction)gamesMode:(id)sender;



//-------------------------------------------------------------------------------------------
// Controlling preferences
- (IBAction)forceGameDefinitionsUpdate:(id)sender;
- (IBAction)updateIdleTimer:(id)sender;
- (IBAction)updateVolume:(id)sender;
- (IBAction)moreSoundsets:(id)sender;

@end
