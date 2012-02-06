//
//  BFChatLogViewer.m
//  BlackFire
//
//  Created by Antwan van Houdt on 2/3/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFChatLogViewer.h"
#import "BFApplicationSupport.h"
#import "BFChatLog.h"
#import <sqlite3.h>

@implementation BFChatLogViewer

@synthesize friendsList = _friendsList;
@synthesize chatlogList	= _chatlogList;
@synthesize chatlogView	= _chatlogView;

- (id)init
{
	if( (self = [super initWithWindowNibName:@"ChatLogViewer"]) )
	{
		_friends	= [[NSMutableArray alloc] init];
		_chats		= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_friends release];
	_friends = nil;
	[_chats release];
	_chats = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	[_friends release];
	_friends = [[NSMutableArray alloc] init];
	
	NSString *logDir = BFChatLogDirectoryPath();
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logDir error:nil];
	for(NSString *file in contents)
	{
		if( [file rangeOfString:@".xfl"].length > 2 )
		{
			NSArray *components = [file componentsSeparatedByString:@"."];
			if( [components count] > 1 && [[components lastObject] isEqualToString:@"xfl"] )
			{
				[_friends addObject:[components objectAtIndex:0]];
			}
		}
	}
	[_friendsList reloadData];
}

- (IBAction)showWindow:(id)sender
{
	[self.window makeKeyAndOrderFront:self];
	
	[_friends release];
	_friends = [[NSMutableArray alloc] init];
	
	NSString *logDir = BFChatLogDirectoryPath();
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logDir error:nil];
	for(NSString *file in contents)
	{
		if( [file rangeOfString:@".xfl"].length > 2 )
		{
			NSArray *components = [file componentsSeparatedByString:@"."];
			if( [components count] > 1 && [[components lastObject] isEqualToString:@"xfl"] )
			{
				[_friends addObject:[components objectAtIndex:0]];
			}
		}
	}
	[_friendsList reloadData];
}

#pragma mark - Toolbar buttons

- (IBAction)cleanOldChatlogs:(id)sender
{
	NSInteger result = NSRunAlertPanel(@"Delete your entire chat history", @"Are you sure you want to delete your entire chat history? Pressing 'OK' will move all your chatlogs to the trash.", @"OK", @"Cancel", nil);
	if( result != NSOKButton )
		return;
}

- (IBAction)cleanAllChatlogs:(id)sender
{
	NSInteger result = NSRunAlertPanel(@"Delete your entire chat history", @"Are you sure you want to delete your entire chat history? Pressing 'OK' will move all your chatlogs to the trash.", @"OK", @"Cancel", nil);
	if( result != NSOKButton )
		return;
	NSString *dirPath = BFChatLogDirectoryPath();
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	NSInteger tag;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
	if( [contents count] > 0 )
	{
		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation source:dirPath destination:trashDir files:contents tag:&tag];
	}
	[_friends release];
	_friends = [[NSMutableArray alloc] init];
	[_friendsList reloadData];
}

- (IBAction)saveChatlog:(id)sender
{
	
}

#pragma mark - Tableview datasource & delegate

- (void)loadChatsForDatabase:(NSString *)filePath
{
	[_chats release];
	_chats = [[NSMutableArray alloc] init];
	sqlite3 *database;
    sqlite3_open([filePath UTF8String], &database);
    if( ! database )
    {
		NSRunAlertPanel(@"Cannot open file", @"", @"OK", nil, nil);
        NSLog(@"*** Can't open the chats for path %@",filePath);
        return;
    }
    sqlite3_stmt *statement = nil;
    
    if( sqlite3_prepare_v2(database, "select * from chats", -1, &statement, NULL) == SQLITE_OK )
    {
        while( sqlite3_step(statement) == SQLITE_ROW )
        {
            unsigned long timestamp = sqlite3_column_int64(statement, 1);
            unsigned int chat		= sqlite3_column_int(statement, 0);
            if( timestamp != 0 )
            {
				NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSince1970:timestamp]],@"name",
									  [NSNumber numberWithUnsignedInt:chat],@"chatID",
									  nil];
				[_chats addObject:dict];
                [dict release];
            }
        }
    }
	[_chatlogList reloadData];
}

- (IBAction)selectedAFriend:(id)sender
{
	NSInteger selectedIndex = [_friendsList selectedRow];
	//NSInteger clickedIndex = [_friendsList clickedRow];
	
	NSString *file = [NSString stringWithFormat:@"%@/%@.xfl",BFChatLogDirectoryPath(),[_friends objectAtIndex:selectedIndex]];
	[self loadChatsForDatabase:file];
}

- (IBAction)selectedAChat:(id)sender
{
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if( tableView == _friendsList )
		return [_friends count];
	else if( tableView == _chatlogList )
		return [_chats count];
	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if( tableView == _friendsList )
		return [_friends objectAtIndex:row];
	else if( tableView == _chatlogList )
		return [[_chats objectAtIndex:row] objectForKey:@"name"];
	return nil;
}

@end
