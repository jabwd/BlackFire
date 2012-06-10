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
{
	NSImageView *_avatarView;
	NSTextField *_nicknameField;
	NSTextField *_usernameField;
	NSTextField *_statusField;
	
	NSTextField *_serverAddressField;
	NSTextField *_mapNameField;
	NSTextField *_playersField;
	NSTableView *_playersList;
	
	NSTextField *_mapLabel;
	NSTextField *_playersLabel;
	NSTextField *_serverAddressLabel;
	
	NSBox *_line;
	
	NSArray *players;
}

@property (assign) IBOutlet NSImageView *avatarView;
@property (assign) IBOutlet NSTextField *nicknameField;
@property (assign) IBOutlet NSTextField *usernameField;
@property (assign) IBOutlet NSTextField *statusField;
@property (assign) IBOutlet NSTextField *serverAddressField;
@property (assign) IBOutlet NSTextField *mapNameField;
@property (assign) IBOutlet NSTextField *playersField;
@property (assign) IBOutlet NSTableView *playersList;

@property (assign) IBOutlet NSTextField *playersLabel;
@property (assign) IBOutlet NSTextField *mapLabel;
@property (assign) IBOutlet NSTextField *serverAddressLabel;

@property (assign) IBOutlet NSBox *line;

+ (BFFriendInformationViewController *)friendInformationController;

/*
 * Populates the sidebar with information from the given friend.
 */
- (void)updateForFriend:(XFFriend *)friend;

@end
