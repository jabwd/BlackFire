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

@synthesize searchField = _searchField;
@synthesize tableView	= _tableView;
@synthesize selectedFriend = _selectedFriend;

@synthesize searchResults = _searchResults;

- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super init]) )
	{
		_mainWindow = mainWindow;
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
	[_searchResults release];
	_searchResults = nil;
	[_selectedFriend release];
	_selectedFriend = nil;
	[super dealloc];
}

- (IBAction)doneAction:(id)sender
{
	[_selectedFriend release];
	_selectedFriend = [[_searchResults objectAtIndex:[_tableView selectedRow]] retain];
	[_tableView setDelegate:nil];
	[_tableView setDataSource:nil];
	[super doneAction:sender];
}

- (IBAction)startSearching:(id)sender
{
	if(! [_delegate isKindOfClass:[ADAppDelegate class]] )
		return;
	
	ADAppDelegate *app = (ADAppDelegate *)_delegate;
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
	XFFriend *friend = [_searchResults objectAtIndex:row];
	if( [[tableColumn identifier] isEqualToString:@"username"] )
		return friend.username;
	else if( [[tableColumn identifier] isEqualToString:@"firstname"] )
		return friend.firstName;
	return friend.lastName;
}

@end
