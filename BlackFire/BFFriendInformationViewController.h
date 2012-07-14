//
//  BFFriendInformationViewController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 6/9/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFInfoViewController.h"
#import "BFGameServerInformation.h"

@class XFFriend;

@interface BFFriendInformationViewController : BFInfoViewController <BFGameServerInformationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (unsafe_unretained) IBOutlet NSImageView *avatarView;
@property (unsafe_unretained) IBOutlet NSTextField *nicknameField;
@property (unsafe_unretained) IBOutlet NSTextField *usernameField;
@property (unsafe_unretained) IBOutlet NSTextField *statusField;
@property (unsafe_unretained) IBOutlet NSTextField *serverAddressField;
@property (unsafe_unretained) IBOutlet NSTextField *mapNameField;
@property (unsafe_unretained) IBOutlet NSTextField *playersField;
@property (unsafe_unretained) IBOutlet NSTableView *playersList;
@property (unsafe_unretained) IBOutlet NSTextField *nameField;

@property (unsafe_unretained) IBOutlet NSTextField *playersLabel;
@property (unsafe_unretained) IBOutlet NSTextField *mapLabel;
@property (unsafe_unretained) IBOutlet NSTextField *serverAddressLabel;
@property (unsafe_unretained) IBOutlet NSTextField *progressLabel;
@property (unsafe_unretained) IBOutlet NSTextField *nameLabel;

@property (unsafe_unretained) IBOutlet NSProgressIndicator *progressIndicator;

@property (unsafe_unretained) IBOutlet NSBox *line;

+ (BFFriendInformationViewController *)friendInformationController;

/*
 * Populates the sidebar with information from the given friend.
 */
- (void)updateForFriend:(XFFriend *)friend;

@end
