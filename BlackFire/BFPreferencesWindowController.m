//
//  BFPreferencesWindow.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/14/09.
//  Copyright 2009 Excurion. All rights reserved.
//

#import "BFPreferencesWindowController.h"

@implementation BFPreferencesWindowController

@synthesize generalView			= _generalView;
@synthesize generalItem			= _generalItem;
@synthesize defaultsController	= _defaultsController;

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
	[self changeToMode:generalMode];
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
	[self changeToMode:generalMode];
}

// switches the window content view to another view
// removes its subviews and addss the one of the new view.
// also resizes the window if needed.
- (void)changeToMode:(BFPrefsMode)aMode
{
	// make sure all the settings are up-to-date
	[_defaultsController save:nil];
	switch( aMode )
	{
		case generalMode:
			[self removeAllSubviews:_generalView];
			break;
	}
}

- (void)removeAllSubviews:(NSView *)aView
{
	NSWindow *window = [self window];
	NSView *mainView = [window contentView];
	
	NSArray *subViews = [mainView subviews];
	[subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	/*NSUInteger i, cnt = [subViews count];
	for(i=0; i < cnt ; i++)
	{
		[[subViews objectAtIndex:i] removeFromSuperview];
	}*/
	
	NSRect frame      = window.frame;
	NSRect frameMain  = mainView.frame;
	NSRect frameView  = aView.frame;
	
	// now we know whether our window has to grow (or get smaller when its negative)
	float ADDITIONS_HEIGHT = frameView.size.height - frameMain.size.height;
	frame.size.height += ADDITIONS_HEIGHT;
	frame.origin.y    -= ADDITIONS_HEIGHT;
	
	[window setFrame:frame display:YES animate:YES];
	
	[mainView addSubview:aView];
	aView.frame = mainView.bounds;
}

@end
