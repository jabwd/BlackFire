//
//  ADInvitationWindowController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 12/14/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "ADInvitationWindowController.h"
#import "XFFriend.h"
#import "ADAppDelegate.h"

@implementation ADInvitationWindowController



- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super initWithWindow:mainWindow]) )
	{
		_selectedFriend = nil;
		
		[NSBundle loadNibNamed:@"InvitationWindow" owner:self];
	}
	return self;
}

- (void)dealloc
{
	[_tableView setDataSource:nil];
	[_tableView setDelegate:nil];
	_tableView = nil;
}

- (IBAction)doneAction:(id)sender
{
	_selectedFriend = _searchResults[[_tableView selectedRow]];
	[_tableView setDelegate:nil];
	[_tableView setDataSource:nil];
	[super doneAction:sender];
}

- (IBAction)startSearching:(id)sender
{
	if(! [self.delegate isKindOfClass:[ADAppDelegate class]] )
		return;
	
	ADAppDelegate *app = (ADAppDelegate *)self.delegate;
	[app startUserSearching:_searchField.stringValue];
}

- (NSString *)invitationMessage
{
	return self.messageField.stringValue;
}

#pragma mark - TableView datasource

- (void)reloadData
{
	[_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_searchResults count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	XFFriend *friend = _searchResults[row];
	if( [[tableColumn identifier] isEqualToString:@"username"] )
		return friend.username;
	else if( [[tableColumn identifier] isEqualToString:@"firstname"] )
		return friend.firstName;
	return friend.lastName;
}

@end
