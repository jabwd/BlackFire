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

@synthesize searchResults = _searchResults;

- (id)initWithWindow:(NSWindow *)mainWindow
{
	if( (self = [super init]) )
	{
		_mainWindow = mainWindow;
		
		[NSBundle loadNibNamed:@"InvitationWindow" owner:self];
	}
	return self;
}

- (void)dealloc
{
	[_searchResults release];
	_searchResults = nil;
	[super dealloc];
}

- (IBAction)startSearching:(id)sender
{
	if(! [_delegate isKindOfClass:[ADAppDelegate class]] )
		return;
	
	ADAppDelegate *app = (ADAppDelegate *)_delegate;
	[app startUserSearching:_searchField.stringValue];
}

- (XFFriend *)selectedFriend
{
	XFFriend *selected = [_searchResults objectAtIndex:[_tableView selectedRow]];
	return selected;
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
