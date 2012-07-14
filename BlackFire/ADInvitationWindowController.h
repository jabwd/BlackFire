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

@property (unsafe_unretained) IBOutlet NSTextField	*searchField;
@property (unsafe_unretained) IBOutlet NSTableView		*tableView;
@property (readonly) XFFriend *selectedFriend;

@property (nonatomic, strong) NSMutableArray *searchResults;

- (IBAction)startSearching:(id)sender;

- (NSString *)invitationMessage;
- (void)reloadData;

@end
