//
//  BFInformationViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 3/2/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFTabViewController.h"

@class XFFriend;

@interface BFInformationViewController : BFTabViewController
{
	XFFriend *_currentFriend;
	
	NSTextField *_usernameField;
	NSTextField *_nicknameField;
	NSTextField *_statusField;
	
	NSImageView *_avatarView;
}

@property (assign) IBOutlet NSTextField *usernameField;
@property (assign) IBOutlet NSTextField *nicknameField;
@property (assign) IBOutlet NSTextField *statusField;

@property (assign) IBOutlet NSImageView *avatarView;

- (void)setFriend:(XFFriend *)remoteFriend;

@end
