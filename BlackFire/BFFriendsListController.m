//
//  BFFriendsListController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/6/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFFriendsListController.h"
#import "BFImageAndTextCell.h"
#import "BFGamesManager.h"

#import "ADAppDelegate.h"

#import "XFSession.h"
#import "XFGroupController.h"
#import "XFGroup.h"
#import "XFFriend.h"

#import "BFDefaults.h"

@implementation BFFriendsListController

@synthesize friendsList = _friendsList;

- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"FriendsList" owner:self];
		NSTableColumn *column = [[_friendsList tableColumns] objectAtIndex:0];
		BFImageAndTextCell *cell = [column dataCell];
		[cell setEditable:NO];
		[cell setDisplayImageSize:NSMakeSize(24.0f, 24.0f)];
		
		[_friendsList setDoubleAction:@selector(doubleClicked)];
		[_friendsList setTarget:self];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)reloadData
{
	[_friendsList reloadData];
}

- (void)expandItem:(id)item
{
	[_friendsList expandItem:item];
}

#pragma mark - Friends list menu

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	XFFriend *selectedFriend = [self selectedFriend];
	switch([menuItem tag])
	{
		case 1: // show profile
		{
			if( [selectedFriend.username length] > 0 )
				return true;
		}
			break;
			
		case 2: // remove friend
		{
			if( !selectedFriend.clanFriend && !selectedFriend.friendOfFriend )
				return true;
		}
			break;
	}
	return false;
}

- (IBAction)removeFriend:(id)sender
{
	if( _delegate )
		[_delegate removeSelectedFriend:sender];
}

- (IBAction)showProfile:(id)sender
{
	if( _delegate )
		[_delegate showProfile:sender];
}


#pragma mark - Outlineview datasource

- (NSUInteger)selectedRow
{
	NSUInteger selectedRow = [_friendsList selectedRow];
	if( [_friendsList clickedRow] != selectedRow )
	{
		return [_friendsList clickedRow];
	}
	return selectedRow;
}

- (void)doubleClicked
{
	// this also allows with offline friends, so someone can "observe" his online status
	XFFriend *selectedFriend = [self selectedFriend];
	if( selectedFriend )
	{
		[_delegate beginChatWithFriend:selectedFriend];
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if( item == nil )
	{
		return [_delegate.session.groupController.groups count];
	}
	else if( [item isKindOfClass:[XFGroup class]] )
	{
		XFGroup *group = (XFGroup *)item;
		if( group.groupType == XFGroupTypeClanGroup )
		{
			if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFShowOfflineClanFriends] )
				return [group onlineMembersCount];
		}
		return [group membersCount];
	}
	return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if( item == nil || [item isKindOfClass:[XFGroup class]] )
		return true;
	return false;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if( item == nil )
	{
		return [_delegate.session.groupController.groups objectAtIndex:index];
	}
	else if( [item isKindOfClass:[XFGroup class]] )
	{
		XFGroup *group = (XFGroup *)item;
		if( group.groupType == XFGroupTypeClanGroup )
		{
			// don't handle the "else" clause here as the default behavior of the method is fine if this 
			// pref is on "true"
			if( ![[NSUserDefaults standardUserDefaults] boolForKey:BFShowOfflineClanFriends] )
			{
				return [group onlineMemberAtIndex:index];
			}
		}
		return [group memberAtIndex:index];
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
	return true;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
	return true;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
	{
		return [(XFGroup *)item name];
	}
	else if( [item isKindOfClass:[XFFriend class]] )
	{
		return [(XFFriend *)item displayName];
	}
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	// below here we configure the tableview cell to display the correct data
	if( [item isKindOfClass:[XFFriend class]] )
	{
		XFFriend			*friend			= (XFFriend *)item;
		BFImageAndTextCell	*imageCell		= (BFImageAndTextCell *)cell;
		
		NSString *statusString = friend.status;
		if( ! statusString )
			statusString = @"";
		
		if( friend.gameID > 0 )
		{
			if( [statusString length] > 0 )
			{
				statusString = [NSString stringWithFormat:@"%@, ",statusString];
			}
			
			if( friend.gameIP > 0 )
			{
				statusString = [NSString stringWithFormat:@"%@Playing %@ on %@",statusString,[[BFGamesManager sharedGamesManager] longNameForGameID:friend.gameID],[friend gameIPString]];
			}
			else
			{
				statusString = [NSString stringWithFormat:@"%@Playing %@",statusString,[[BFGamesManager sharedGamesManager] longNameForGameID:friend.gameID]];
			}
			[imageCell setImage:[[BFGamesManager sharedGamesManager] imageForGame:(unsigned int)friend.gameID]];
		}
		else
		{
			if( friend.avatar )
			{
				[imageCell setImage:friend.avatar];
			}
			else
			{
				// determine whether the image exists on the disk
				
				NSImage *image = nil;
				NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
				
				NSString *imagePath = [[NSString alloc] initWithFormat:@"%@/BlackFire/%@.jpg",cachesPath,friend.username];
				if( [[NSFileManager defaultManager] fileExistsAtPath:imagePath] )
				{
					image = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
				}
				else
				{
					image = [NSImage imageNamed:@"xfire"];
				}
				[imagePath release];
				
				[image setScalesWhenResized:true];
				friend.avatar = image;
				[imageCell setImage:image];
			}
		}
		
		// always show this for offline friends
		if( !friend.online )
			statusString = @"Offline";
		
		if( [statusString rangeOfString:@"AFK"].length > 0 )
			[imageCell setFriendStatus:CellStatusAFK];
		else if( friend.online )
			[imageCell setFriendStatus:CellStatusOnline];
		else
			[imageCell setFriendStatus:CellStatusOffline];
		
		if( [statusString length] > 0 )
		{
			[(BFImageAndTextCell *)cell setShowsStatus:true];
			if( friend.gameIP != 0 )
			{
				statusString = [NSString stringWithFormat:@"%@ %@",statusString,[friend gameIPString]];
			}
			[(BFImageAndTextCell *)cell setCellStatusString:statusString];
		}
		else
		{
			[(BFImageAndTextCell *)cell setShowsStatus:false];
		}
		[(BFImageAndTextCell *)cell setGroupRow:false];
	} 
	else
	{
		[(BFImageAndTextCell *)cell setStatusImage:nil];
		[(BFImageAndTextCell *)cell setShowsStatus:NO];
		[(BFImageAndTextCell *)cell setGroupRow:true];
		[cell setImage:nil];
	}
}

- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation
{
	if( [item isKindOfClass:[XFFriend class]] )
	{
		XFFriend *friend = (XFFriend *)item;
		return [NSString stringWithFormat:@"username: %@\nuserID: %u",friend.username,friend.userID];
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
		return true;
	return false;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	if( [item isKindOfClass:[XFGroup class]] )
	{
		return 18.0f;
	}
	return 28.0f;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	XFFriend *remoteFriend = (XFFriend *)item;
	if( [remoteFriend isKindOfClass:[XFFriend class]] )
	{
		[_delegate requestAvatarForFriend:remoteFriend];
	}
	return true;
}



#pragma mark - Getting friends and groups



- (NSInteger)activeRow
{
	// first check the selected row
	NSInteger selRow    = [_friendsList selectedRow];
	NSInteger clickRow  = [_friendsList clickedRow];
	
	if ( selRow == clickRow ) 
		return selRow;
	else if ( clickRow >= 0 )
		return clickRow;
	else 
		return selRow;
	return 0;
}

- (XFFriend *)selectedFriend 
{	
	NSInteger row = [self activeRow];
	
	if( row >= 0 ) 
	{
		id selItem = [_friendsList itemAtRow:row];
		if( [selItem isKindOfClass:[XFFriend class]] ) 
		{
			return selItem;
		}
	}
	return nil;
}

- (XFGroup *)selectedGroup
{
	NSInteger row = [self activeRow];
	if( row >= 0 ){
		id selItem = [_friendsList itemAtRow:row];
		if( [selItem isKindOfClass:[XFGroup class]] )
		{
			return selItem;
		}
		else
		{
			id parent = [_friendsList parentForItem:selItem];
			if( [parent isKindOfClass:[XFGroup class]] )
				return parent;
		}
	}
	return nil;
}

- (XFGroup *)friendGroupForItemAtRow:(NSInteger)row 
{
	NSInteger rowLvl = [_friendsList levelForRow:row];
	NSInteger lvl;
	id item;
	id friendAtRow = [_friendsList itemAtRow:row];
	
	if( ![friendAtRow isKindOfClass:[XFFriend class]] )
		return nil;
	
	while ( row >= 0 ) 
	{
		lvl = [_friendsList levelForRow:row];
		if( lvl < rowLvl ) 
		{
			item = [_friendsList itemAtRow:row];
			if ([item isKindOfClass:[XFGroup class]] &&[item friendIsMember:friendAtRow] ) 
			{
				return item;
			}
		}
		row--;
	}
	
	return nil;
}

- (XFFriend *)selectedFriendNotFoF 
{
	XFFriend *fr = [self selectedFriend];
	if ( !fr.friendOfFriend )
		return fr;
	return nil;
}

- (XFFriend *)selectedOnlineFriendNotFoF 
{
	XFFriend *fr = [self selectedFriendNotFoF];
	if( fr.online )
		return fr;
	return nil;
}

- (XFFriend *)selectedOnlineFriend 
{
	XFFriend *fr = [self selectedFriend];
	if( fr.online )
		return fr;
	return nil;
}


@end
