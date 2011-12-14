//
//  BFFriendsListController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFTabViewController.h"

@class XFSession, XFFriend, XFGroup;

@interface BFFriendsListController : BFTabViewController <NSMenuDelegate ,NSOutlineViewDelegate, NSOutlineViewDataSource>
{
	NSOutlineView *_friendsList;
}

@property (assign) IBOutlet NSOutlineView *friendsList;

- (id)initWithSession:(XFSession *)session;

- (void)reloadData;
- (void)expandItem:(id)item;

//--------------------------------------------------------------------------
// Friends list menu handling

- (IBAction)removeFriend:(id)sender;
- (IBAction)showProfile:(id)sender;

//--------------------------------------------------------------------------
// Getting friends and groups
- (NSInteger)activeRow;
- (XFFriend *)selectedFriend;
- (XFGroup *)selectedGroup;
- (XFGroup *)friendGroupForItemAtRow:(NSInteger)row;
- (XFFriend *)selectedFriendNotFoF;
- (XFFriend *)selectedOnlineFriendNotFoF;
- (XFFriend *)selectedOnlineFriend;

@end
