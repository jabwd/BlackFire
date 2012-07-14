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

@property (unsafe_unretained) IBOutlet NSTextField *usernameField;
@property (unsafe_unretained) IBOutlet NSTextField *nicknameField;
@property (unsafe_unretained) IBOutlet NSTextField *statusField;

@property (unsafe_unretained) IBOutlet NSImageView *avatarView;

- (void)setFriend:(XFFriend *)remoteFriend;

@end
