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
#import "BFNotificationCenter.h"
#import "BFApplicationSupport.h"
#import "BFSoundSet.h"
#import "BFGamesManager.h"

@implementation BFPreferencesWindowController
{
	NSMutableArray *_soundsets;
}

- (id)init
{
	if( (self = [super initWithWindowNibName:@"BFPreferencesWindow"]) )
	{
		_soundsets = nil;
	}
	return self;
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
	self.window.title = @"General";
}

- (IBAction)notificationsMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_notificationsView];
	self.window.title = @"Notifications";
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSString *soundsetsPath = BFSoundsetsDirectoryPath();
		_soundsets = [[NSMutableArray alloc] init];
		NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundsetsPath error:nil];
		if( [contents count] > 0 )
		{
			for(NSString *soundset in contents)
			{
				if( [soundset isEqualToString:@".DS_Store"] )
					continue;
				NSString *finalPath = [[NSString alloc] initWithFormat:@"%@/%@",soundsetsPath,soundset];
				BFSoundSet *set = [[BFSoundSet alloc] initWithContentsOfFile:finalPath];
				if( [set.name length] > 0 )
				{
					[_soundsets addObject:set];
				}
			}
		}
		
		// now update the menu.
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
			NSInteger i, cnt = [_soundsets count];
			NSString *currentPath = [[NSUserDefaults standardUserDefaults] objectForKey:BFSoundSetPath];
			NSMenuItem *current = nil;
			for(i=0;i<cnt;i++)
			{
				BFSoundSet *set = _soundsets[i];
				NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:set.name action:@selector(selectSoundset:) keyEquivalent:@""];
				[item setTarget:self];
				[item setTag:i];
				[menu addItem:item];
				if( [set.path isEqualToString:currentPath] )
					current = item;
			}
			[_soundsetDropDown setMenu:menu];
			if( current )
				[_soundsetDropDown selectItem:current];
			
			if( [_soundsets count] > 0 )
				[_soundsetDropDown setEnabled:true];
			else
				[_soundsetDropDown setEnabled:false];
		});
	});
}

- (IBAction)chatMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_chatView];
	self.window.title = @"Chatting";
}

- (IBAction)gamesMode:(id)sender
{
	[self removeAllSubviewsAndReplaceWithView:_gamesView];
	self.window.title = @"Games";
	
	[_gamesVersionField setStringValue:[NSString stringWithFormat:@"%lu",[[BFGamesManager sharedGamesManager] gamesVersion]]];
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
	
	float add_height = frameView.size.height - frameMain.size.height;
	frame.size.height += add_height;
	frame.origin.y    -= add_height;
	
	[window setFrame:frame display:YES animate:YES];
	
	[mainView addSubview:aView];
	aView.frame = mainView.bounds;
}


#pragma mark - Controlling preferences

- (IBAction)forceGameDefinitionsUpdate:(id)sender
{
	[[BFGamesManager sharedGamesManager] checkForUpdatesAndUpdate];
}

- (IBAction)updateIdleTimer:(id)sender
{	
	[[BFIdleTimeManager defaultManager] setSetAwayStatusAutomatically:[[NSUserDefaults standardUserDefaults] boolForKey:BFAutoGoAFK]];
}

- (IBAction)updateVolume:(id)sender
{
	[[BFNotificationCenter defaultNotificationCenter] updateSoundVolume];
}

- (IBAction)selectSoundset:(id)sender
{
	NSMenuItem *item = (NSMenuItem *)sender;
	if( [item isKindOfClass:[NSMenuItem class]] )
	{
		NSInteger index = [item tag];
		if( index > 0 && index < [_soundsets count] )
		{
			BFSoundSet *soundSet = _soundsets[index];
			if( soundSet )
			{
				[[BFNotificationCenter defaultNotificationCenter] setSoundSet:soundSet];
				[[NSUserDefaults standardUserDefaults] setObject:soundSet.path forKey:BFSoundSetPath];
				[[BFNotificationCenter defaultNotificationCenter] playDemoSound];
			}
		}
	}
	else
		NSLog(@"*** Unknown object %@ called selectSoundset",sender);
}

- (IBAction)moreSoundsets:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.adiumxtras.com/index.php?a=search&cat_id=3"]];
}

@end
