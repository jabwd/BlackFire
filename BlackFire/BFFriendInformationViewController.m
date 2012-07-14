//
//  BFFriendInformationViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/9/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFFriendInformationViewController.h"
#import "XFFriend.h"
#import "XFGameServer.h"
#import "BFGameServerInformation.h"


NSString *getString(NSString *string);
NSString *getString(NSString *string)
{
	if( ! string ) return @"";
	return string;
}
NSString *removeQuakeColorCodes(NSString *string);


@implementation BFFriendInformationViewController
{
	NSArray *players;
}

+ (BFFriendInformationViewController *)friendInformationController
{
	BFFriendInformationViewController *controller = [[BFFriendInformationViewController alloc] initWithNibName:@"BFFriendInformationView" bundle:nil];
	return controller;
}

- (void)dealloc
{
	players = nil;
}

- (void)updateForFriend:(XFFriend *)friend
{
	if( ! friend ) return;
	
	[_statusField setStringValue:getString([friend status])];
	[_nicknameField setStringValue:getString([friend nickname])];
	[_usernameField setStringValue:getString(friend.username)];
	
	if( true )
	{
		NSImage *avatar = [friend.avatar copy];
		if( ! avatar )
			avatar = [NSImage imageNamed:@"xfire"];
		[avatar setScalesWhenResized:true];
		[avatar setSize:[_avatarView frame].size];
		[_avatarView setHidden:false];
		[_avatarView setImage:avatar];
	}
	else {
		[_avatarView setImage:nil];
		[_avatarView setHidden:true];
	}
	
	[_line setHidden:true];
	[_playersField setHidden:true];
	[_mapNameField setHidden:true];
	[_serverAddressLabel setHidden:true];
	[_mapLabel setHidden:true];
	[_playersLabel setHidden:true];
	[_serverAddressField setHidden:true];
	[_nameField setHidden:true];
	[_nameLabel setHidden:true];
	[[[_playersList superview] superview] setHidden:true];
	[_progressLabel setHidden:true];
	
	
	if( friend.gameID > 0 && friend.gameIP > 0 )
	{
		[_progressIndicator startAnimation:nil];
		[_progressIndicator setHidden:false];
		[_progressLabel setHidden:false];
		[_progressLabel setStringValue:@"Loading server info…"];
		
		[[BFGameServerInformation sharedInformation] setDelegate:self];
		[[BFGameServerInformation sharedInformation] getInformationForFriend:friend];
	}
}


- (void)receivedInformationForServer:(XFGameServer *)server
{
	// update the tableview
	if( server.online && server.raw )
	{
		[_progressLabel setHidden:true];
		
		[_line setHidden:false];
		[_playersField setHidden:false];
		[_mapNameField setHidden:false];
		[_serverAddressField setHidden:false];
		[_serverAddressLabel setHidden:false];
		[_playersLabel setHidden:false];
		[_mapLabel setHidden:false];
		[_nameField setHidden:false];
		[_nameLabel setHidden:false];
		
		[_serverAddressField setStringValue:[server address]];
		[_mapNameField setStringValue:[server map]];
		[_playersField setStringValue:[server playerString]];
		[_nameField setStringValue:[server name]];
		
		players = nil;
		
		players = [server players];
		if( [players count] > 0 )
		{
			[[[_playersList superview] superview] setHidden:false];
		}
		[_playersList reloadData];
	}
	else {
		[_progressLabel setStringValue:@"Unable to fetch server info"];
	}
	[_progressIndicator stopAnimation:nil];
	[_progressIndicator setHidden:true];
}

#pragma mark - Player list datasource


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [players count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	id value = players[row][@"name"];
	return removeQuakeColorCodes(value);
}

@end
