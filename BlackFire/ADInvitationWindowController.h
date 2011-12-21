//
//  ADInvitationWindowController.h
//  BlackFire
//
//  Created by Antwan van Houdt on 12/14/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADStringPromptController.h"

@class XFFriend;

@interface ADInvitationWindowController : ADStringPromptController <NSTableViewDelegate, NSTableViewDataSource>
{
	NSMutableArray *_searchResults;
}

@property (assign) IBOutlet NSTextField	*searchField;
@property (assign) IBOutlet NSTableView		*tableView;

@property (nonatomic, retain) NSMutableArray *searchResults;

- (IBAction)startSearching:(id)sender;

- (XFFriend *)selectedFriend;
- (NSString *)invitationMessage;
- (void)reloadData;

@end
