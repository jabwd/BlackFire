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
	XFFriend		*_selectedFriend;
}

@property (assign) IBOutlet NSTextField	*searchField;
@property (assign) IBOutlet NSTableView		*tableView;
@property (readonly) XFFriend *selectedFriend;

@property (nonatomic, retain) NSMutableArray *searchResults;

- (IBAction)startSearching:(id)sender;

- (NSString *)invitationMessage;
- (void)reloadData;

@end
