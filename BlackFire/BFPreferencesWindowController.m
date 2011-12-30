//
//  BFPreferencesWindow.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/14/09.
//  Copyright 2009 Excurion. All rights reserved.
//

#import "BFPreferencesWindowController.h"
#import "BFIdleTimeManager.h"
#import "BFDefaults.h"

@implementation BFPreferencesWindowController

@synthesize generalView			= _generalView;
@synthesize notificationsView	= _notificationsView;
@synthesize chatView			= _chatView;
@synthesize gamesView			= _gamesView;

@synthesize generalItem			= _generalItem;

- (id)init
{
	if( (self = [super initWithWindowNibName:@"BFPreferencesWindow"]) )
	{
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)awakeFromNib
{
	[[[self window] toolbar] setSelectedItemIdentifier:[_generalItem itemIdentifier]];
	[self generalMode:nil];
	[self showWindow:self];
}

#pragma mark - Handling the window & toolbar

- (IBAction)showWindow:(id)sender 
{
	NSWindow *window = [self window];
	if (![window isVisible]) 
	{
		[window center];
	}
	[window makeKeyAndOrderFront:self];
}

- (BOOL)windowShouldClose:(id)sender
{
	return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem 
{
	return YES;
}


#pragma mark - Mode changing

- (IBAction)generalMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_generalView];
}

- (IBAction)notificationsMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_notificationsView];
}

- (IBAction)chatMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_chatView];
}

- (IBAction)gamesMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_gamesView];
}

- (void)removeAllSubviewsAndReplaceWithView:(NSView *)aView
{
	NSWindow *window = [self window];
	NSView *mainView = [window contentView];
	
	NSArray *subViews = [mainView subviews];
	[subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSRect frame      = window.frame;
	NSRect frameMain  = mainView.frame;
	NSRect frameView  = aView.frame;
	
	float ADDITIONS_HEIGHT = frameView.size.height - frameMain.size.height;
	frame.size.height += ADDITIONS_HEIGHT;
	frame.origin.y    -= ADDITIONS_HEIGHT;
	
	[window setFrame:frame display:YES animate:YES];
	
	[mainView addSubview:aView];
	aView.frame = mainView.bounds;
}


#pragma mark - Controlling preferences

- (IBAction)updateIdleTimer:(id)sender
{	
	[[BFIdleTimeManager defaultManager] setSetAwayStatusAutomatically:[[NSUserDefaults standardUserDefaults] boolForKey:BFAutoGoAFK]];
}

@end
