//
//  BFServerListController.m
//  BlackFire
//
//  Created by Antwan van Houdt on 7/22/10.
//  Copyright 2010 Excurion. All rights reserved.
//

#import "BFServerListController.h"
#import "BFGamesManager.h"
#import "BFImageAndTextCell.h"
#import "XFGameServer.h"
#import "XFSession.h"
#import "ADOutlineView.h"


@implementation BFServerListController

@synthesize serverListView	= _serverListView;
@synthesize session			= _session;


- (id)initWithSession:(XFSession *)session
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"ServerList" owner:self];
		
		_session	= [session retain];
		taskList	= [[NSMutableArray alloc] init];
		_serverList	= [session.serverList retain];
		
		
		NSTableColumn *col = [_serverListView tableColumnWithIdentifier:@"server"];
		BFImageAndTextCell *cell = [[BFImageAndTextCell alloc] init];
		[cell setEditable:NO];
		[cell setDisplayImageSize:NSMakeSize(24.0f,24.0f)];
		[col  setDataCell:cell];
		[cell release];
		[_serverListView setDoubleAction:@selector(doubleClicked:)];
	}
	return self;
}

- (void)dealloc
{
	[serverInfoOutput release];
	serverInfoOutput = nil;
	[taskList release];
	taskList = nil;
	[_serverList release];
	_serverList = nil;
	[_session release];
	_session = nil;
	[super dealloc];
}

- (IBAction)clicked:(id)sender
{
	XFGameServer *selected = [self selectedServer];
	if( ! task && selected )
	{
		// TODO: Fetch game Name for game ID
		// NSString *gameName = [[[BFGamesManager sharedManager] gameInfo:[[selected objectForKey:@"gameID"] intValue]] objectForKey:@""];
		NSString *gameType = [[BFGamesManager sharedGamesManager] serverTypeForGID:selected.gameID];
		[self getServerInfoWithIP:[selected address] andGameName:gameType];
	}
	else if( task )
	{
		[taskList release];
		taskList = [[NSMutableArray alloc] init];
		[task stopProcess]; // to be sure
		[task release];
		task = nil;
		[self clicked:sender]; // repeat the process
	}
}

- (IBAction)refresh:(id)sender
{
	XFGameServer *selected = [self selectedServer];
	if( ! task && selected )
	{
		// TODO: Fetch game Name for game ID
		// NSString *gameName = [[[BFGamesManager sharedManager] gameInfo:[[selected objectForKey:@"gameID"] intValue]] objectForKey:@""];
		NSString *gameType = [[BFGamesManager sharedGamesManager] serverTypeForGID:selected.gameID];
		[self getServerInfoWithIP:[selected address] andGameName:gameType];
	}
	else if( task )
	{
		[taskList release];
		taskList = [[NSMutableArray alloc] init];
		[task stopProcess]; // to be sure
		[task release];
		task = nil;
		[self refresh:sender]; // repeat the process
	}
}

- (IBAction)refreshAll:(id)sender
{
	[taskList release];
	taskList = [[NSMutableArray alloc] init];
	for(XFGameServer *dict in _serverList)
	{
		[taskList addObject:dict];
	}
	[self nextTask];
}

- (IBAction) doubleClicked:(id)sender
{
	XFGameServer *dict = [self selectedServer];
	[[BFGamesManager sharedGamesManager] launchGame:dict.gameID withAddress:[dict address]];
}

#pragma mark - Getting server information

- (void) processStarted
{
}

- (void) processFinished
{
	if( ! serverInfoOutput )
		return;
	id serverInfo = [serverInfoOutput propertyList];
	if ([serverInfo isKindOfClass:[NSDictionary class]]) 
	{
		if(	! [[serverInfo objectForKey:@"status"] isEqualToString:@"UP"] )
		{
			NSString *ip = [serverInfo objectForKey:@"address"];
			for(XFGameServer *server in _serverList)
			{
				if( [[server address] isEqualToString:ip] )
				{
					server.name = @"Server offline";
					[_serverListView reloadData];
					break; // not done here
				}
			}
			[_serverListView reloadData];
			[serverInfoOutput release];
			serverInfoOutput = nil;
			/*
			 * Perform all the tasks set in our tasks Que
			 */
			if( [taskList count] > 0 )
			{
				[self performSelector:@selector(nextTask) withObject:nil afterDelay:0.1];
			}
			return; // the server is offline
		}
		NSString *name = removeQuakeColorCodes([serverInfo objectForKey:@"name"]);
		NSString *ip   = [serverInfo objectForKey:@"address"];
		if( name )
		{
			for(XFGameServer *server in _serverList)
			{
				if( [[server address] isEqualToString:ip] )
				{
					server.name = name;
					[_serverListView reloadData];
					break; // not done here
				}
			}
		}
	}
	[serverInfoOutput release];
	serverInfoOutput = nil;
	
	/*
	 * Perform all the tasks set in our tasks Que
	 */
	if( [taskList count] > 0 )
	{
		[self performSelector:@selector(nextTask) withObject:nil afterDelay:0.1];
	}
}

NSString *removeQuakeColorCodes(NSString *string)
{
	NSRange range = [string rangeOfString:@"^"];
	while(range.length > 0)
	{
		NSRange actualRange = NSMakeRange(range.location, 2);
		if( (range.location+2) <= [string length] )
		{
			string = [string stringByReplacingCharactersInRange:actualRange withString:@""];
		}
		range = [string rangeOfString:@"^"];
	}
	return string;
}

- (void)appendOutput:(NSString *)output
{
	if( ! serverInfoOutput )
		serverInfoOutput = [[NSMutableString alloc] init];
	NSString *buffer = [[NSString alloc] initWithData:[output dataUsingEncoding:NSASCIIStringEncoding] encoding:NSASCIIStringEncoding];
	[serverInfoOutput appendString:buffer];
	[buffer release];
}

- (void)nextTask
{
	if( [taskList count] > 0 )
	{
		XFGameServer *server = [taskList lastObject];
		[self getServerInfoWithIP:[server address] andGameName:[[BFGamesManager sharedGamesManager] serverTypeForGID:server.gameID]];
		[taskList removeLastObject];
	}
}

- (void)getServerInfoWithIP:(NSString *)ip andGameName:(NSString *)gameName
{
	if( task )
	{
		[task stopProcess];
		[task release];
		task = nil;
	}
	
	if( ! gameName ) gameName = @"-q3s";
	if( ! ip   ) return;
	
	NSArray *arguments = [[NSArray alloc] initWithObjects:@"-nh",
						  @"-P",
						  @"-plist",
						  @"-cfg",
						  [[NSBundle mainBundle] pathForResource:@"server" ofType:@"cfg"],
						  gameName,
						  ip,
						  nil];
	NSString *qstatPath = [[NSBundle mainBundle] pathForResource:@"qstat" ofType:@""];
	if( ! qstatPath )
	{
		NSRunAlertPanel(@"Error", @"BlackFire is not properly installed, please reinstall the application", @"OK", nil, nil);
		NSLog(@"*** QSTAT Path invalid, application bundle is not correct");
		[arguments release];
		return;
	}
	task = [[TaskWrapper alloc] initWithController:self arguments:arguments];
	[task startProcess:qstatPath];
	[arguments release];
}

- (XFGameServer *)selectedServer
{
	NSInteger activeRow = [self activeRow];
	if( activeRow < [_serverList count] )
	{
		return [_serverList objectAtIndex:activeRow];
	}
	return nil;
}

- (NSInteger)activeRow 
{
	NSInteger selRow    = [_serverListView selectedRow];
	NSInteger clickRow  = [_serverListView clickedRow];
	
	if ( selRow == clickRow ) 
	{
		return selRow;
	} 
	else if ( clickRow >= 0 ) 
	{
		return clickRow;
	} 
	else 
	{
		return selRow;
	}
	return 0;
}

- (BOOL) validateMenuItem:(NSMenuItem *)anItem
{
	return YES;
}

#pragma mark -
#pragma mark EXOutlineView datasource

- (id) outlineView:(NSOutlineView *)olView child:(int)index ofItem:(id)item {
	return [_serverList objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView isItemExpandable:(id)item {
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView shouldExpandItem:(id)item {
	return YES;
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView shouldCollapseItem:(id)item{
	return YES;
}

- (NSUInteger)outlineView:(NSOutlineView *)anOutlineView numberOfChildrenOfItem:(id)item 
{
	return [_serverList count];
}

- (id)outlineView:(NSOutlineView *)anOutlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item 
{
	if( !item ) 
		return nil;
	
	if( [item isKindOfClass:[XFGameServer class]] )
	{
		XFGameServer *server = (XFGameServer *)item;
		if( [server.name length] > 0 )
		{
			return server.name;
		}
		else
			return [server address];
	}
	return nil;
}

- (id)outlineView:(NSOutlineView *)anOutlineView itemForPersistentObject:(id)object
{
	return nil;
}

- (id)outlineView:(NSOutlineView *)anOutlineView persistentObjectForItem:(id)item
{
	if( !item ) 
		return nil;
	
	if( [item isKindOfClass:[XFGameServer class]] )
	{
		XFGameServer *server = (XFGameServer *)item;
		if( [server.name length] > 0 )
		{
			return server.name;
		}
		else
			return [server address];
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return NO;
}

- (void)outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if( cell && [item isKindOfClass:[XFGameServer class]] )
    {
		[(BFImageAndTextCell *)cell setGroupRow:false];
		XFGameServer *server = (XFGameServer *)item;
		unsigned int gameID = server.gameID;
		NSString *name = server.name;
		if( gameID != 0 )
		{
			[(BFImageAndTextCell *)cell setImage:[[BFGamesManager sharedGamesManager] imageForGame:gameID]];
		}
		else 
		{
			[(BFImageAndTextCell *)cell setImage:[NSImage imageNamed:@"blackfire"]];
		}
		if( name && [name length] > 0 )
		{
			[(BFImageAndTextCell *)cell setCellStatusString:[server address]];
			[(BFImageAndTextCell *)cell setStringValue:name];
			[(BFImageAndTextCell *)cell setShowsStatus:YES];
		}
		else {
			[(BFImageAndTextCell *)cell setShowsStatus:NO];
		}
		
    }
}

- (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation 
{
	return nil;
}

// Copy something about this friend to the pasteboard for friend dragging (used to add friends to custom groups)
- (BOOL)outlineView:(NSOutlineView *)ov writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
	return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)proposedItem proposedChildIndex:(int)index {
	return NSDragOperationNone;
}

- (CGFloat)outlineView:(NSOutlineView *)anOutlineView heightOfRowByItem:(id)item {
	if( (item == nil) || ([anOutlineView isExpandable:item]) ){
		return 14.0f;
	}
	return 28.0f;
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
	return NO;
}

@end
