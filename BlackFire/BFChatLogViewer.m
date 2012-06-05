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
#import "XFSession.h"
#import "XFFriend.h"

@implementation BFChatLogViewer

@synthesize friendsList = _friendsList;
@synthesize chatlogList	= _chatlogList;
@synthesize chatlogView	= _chatlogView;
@synthesize session = _session;

- (id)init
{
	if( (self = [super initWithWindowNibName:@"ChatLogViewer"]) )
	{
		_friends            = [[NSMutableArray alloc] init];
		_chats              = [[NSMutableArray alloc] init];
        _currentDatabase    = NULL;
        _session            = nil;
	}
	return self;
}

- (void)dealloc
{
	[_friends release];
	_friends = nil;
	[_chats release];
	_chats = nil;
    _session = nil;
    if( _currentDatabase )
    {
        sqlite3_close(_currentDatabase);
        _currentDatabase = NULL;
    }
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
	if( _currentDatabase )
    {
        sqlite3_close(_currentDatabase);
        _currentDatabase = NULL;
    }
    sqlite3_open([filePath UTF8String], &_currentDatabase);
    if( ! _currentDatabase )
    {
		NSRunAlertPanel(@"Cannot open file", @"", @"OK", nil, nil);
        NSLog(@"*** Can't open the chats for path %@",filePath);
        return;
    }
    sqlite3_stmt *statement = nil;
    
    if( sqlite3_prepare_v2(_currentDatabase, "select * from chats", -1, &statement, NULL) == SQLITE_OK )
    {
        while( sqlite3_step(statement) == SQLITE_ROW )
        {
            unsigned long timestamp = (unsigned long)sqlite3_column_int64(statement, 1);
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
	
	NSString *file = [NSString stringWithFormat:@"%@/%@.xfl",BFChatLogDirectoryPath(),[_friends objectAtIndex:selectedIndex]];
	[self loadChatsForDatabase:file];
}

- (IBAction)selectedAChat:(id)sender
{
	NSInteger idx = [_chatlogList selectedRow];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@""];
    [[_chatlogView textStorage] setAttributedString:str];
    [str release];
    
    NSString *username = [_friends objectAtIndex:[_friendsList selectedRow]];
    
    if( idx >= 0 )
    {
        NSInteger chatID = [[[_chats objectAtIndex:idx] objectForKey:@"chatID"] integerValue];
        if( chatID )
        {
            sqlite3_stmt *statement = nil;
            NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM messages WHERE chatID=%lu ORDER BY timestamp",chatID];
            if( sqlite3_prepare_v2(_currentDatabase, [query UTF8String], -1, &statement, NULL) == SQLITE_OK )
            {
                NSTextStorage *storage = [_chatlogView textStorage];
                while(sqlite3_step(statement)==SQLITE_ROW)
                {
                    NSInteger user = sqlite3_column_int(statement, 2);
                    const char *message = (const char*)sqlite3_column_text(statement, 4);
                    
                    if( message )
                    {
                        NSString *nickname = nil;
                        NSDictionary *attr  = nil;
                        if( !user )
                        {
                            nickname = [[_session loginIdentity] displayName];
                            attr = [[NSDictionary alloc] initWithObjectsAndKeys:NSForegroundColorAttributeName,[NSColor blueColor], nil];
                        }
                        else if( user == 1 ) {
                            nickname = [[_session friendForUsername:username] displayName];
                            attr = [[NSDictionary alloc] initWithObjectsAndKeys:NSForegroundColorAttributeName,[NSColor redColor], nil];
                        }
                        else {
                            nickname = @"";
                            attr = [[NSDictionary alloc] initWithObjectsAndKeys:NSForegroundColorAttributeName,[NSColor grayColor], nil];
                        }
                        if( ! nickname )
                            nickname = @"Unknown";
						 attr = [[NSDictionary alloc] initWithObjectsAndKeys:NSForegroundColorAttributeName,[NSColor blueColor], nil];
						
						NSString *newLine = @"";
						if( [storage length] > 0)
							newLine = @"\n";
                        NSString *fmtStr    = [[NSString alloc] initWithFormat:@"%@%@: %s",newLine,nickname,message];
                        NSMutableAttributedString *mtb = [[NSMutableAttributedString alloc] initWithString:fmtStr];
                        [mtb setAttributes:attr range:NSMakeRange([newLine length], [nickname length])];
                        [storage appendAttributedString:mtb];
                        [mtb release];
                        [attr release];
                        [fmtStr release];
                    }
                }
            }
            sqlite3_finalize(statement);
            [query release];
        }
    }
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
