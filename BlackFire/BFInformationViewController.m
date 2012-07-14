//
//  BFInformationViewController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 3/2/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFInformationViewController.h"
#import "XFFriend.h"

@implementation BFInformationViewController
{
	XFFriend *_currentFriend;
}

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"InformationView" owner:self];
	}
	return self;
}

- (void)dealloc
{
	_currentFriend = nil;
}

#pragma mark - Implementation

- (void)setFriend:(XFFriend *)remoteFriend
{
	_currentFriend = nil;
	_currentFriend = remoteFriend;
	
	if( ! _currentFriend )
	{
		DLog(@"[Warning] BFInformationViewController is not supposed to handle an empty XFFriend object! make sure its off screen so the user won't notice the empty information");
	}
	else {
		[self updateView];
	}
}

- (void)updateView
{
	if( _currentFriend )
	{
		if( [[_currentFriend nickname] length] > 0 )
		{
			[_nicknameField setStringValue:[_currentFriend nickname]];
			[_usernameField setStringValue:[_currentFriend username]];
		}
		else {
			[_usernameField setStringValue:@""];
			[_nicknameField setStringValue:[_currentFriend username]];
		}
		NSString *status = [_currentFriend status];
		if( ! status )
			status = @"";
		[_statusField setStringValue:status];
		NSImage *avatar = [[_currentFriend avatar] copy];
		[avatar setScalesWhenResized:true];
		[avatar setSize:NSMakeSize(64, 64)];
		[_avatarView setImage:avatar];
	}
}

@end
