//
//  BFFriendInformationViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/9/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFFriendInformationViewController.h"
#import "XFFriend.h"


NSString *getString(NSString *string);
NSString *getString(NSString *string)
{
	if( ! string ) return @"";
	return string;
}


@implementation BFFriendInformationViewController

@synthesize avatarView			= _avatarView;
@synthesize nicknameField		= _nicknameField;
@synthesize usernameField		= _usernameField;
@synthesize statusField			= _statusField;
@synthesize serverAddressField	= _serverAddressField;
@synthesize mapNameField		= _mapNameField;
@synthesize playersList			= _playersList;
@synthesize playersField		= _playersField;
@synthesize line				= _line;

+ (BFFriendInformationViewController *)friendInformationController
{
	BFFriendInformationViewController *controller = [[BFFriendInformationViewController alloc] initWithNibName:@"BFFriendInformationView" bundle:nil];
	return [controller autorelease];
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
			avatar = [[NSImage imageNamed:@"xfire"] retain];
		[avatar setScalesWhenResized:true];
		[avatar setSize:[_avatarView frame].size];
		[_avatarView setHidden:false];
		[_avatarView setImage:avatar];
		[avatar release];
	}
	else {
		[_avatarView setImage:nil];
		[_avatarView setHidden:true];
	}
	
	
	if( friend.gameID > 0 && friend.gameIP > 0 )
	{
		// populate the players list
	}
}



@end
