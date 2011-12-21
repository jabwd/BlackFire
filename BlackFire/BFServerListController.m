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


@implementation BFServerListController

@synthesize serverListView;
@synthesize delegate;


- (id)init
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"ServerList" owner:self];
		serverList = nil;
		NSTableColumn *col = [serverListView tableColumnWithIdentifier:@"server"];
		taskList = [[NSMutableArray alloc] init];
		BFImageAndTextCell *cell = [[BFImageAndTextCell alloc] init];
		[cell setEditable:NO];
		[cell setDisplayImageSize:NSMakeSize(23.0f,23.0f)];
		[col  setDataCell:cell];
		[cell release];
		[serverListView setDoubleAction:@selector(doubleClicked:)];
	}
	return self;
}

- (id)initWithServerList:(NSArray *)newList
{
	if( (self = [super init]) )
	{
		[NSBundle loadNibNamed:@"ServerList" owner:self];
		serverList = [newList retain];
		NSTableColumn *col = [serverListView tableColumnWithIdentifier:@"server"];
		taskList = [[NSMutableArray alloc] init];
		BFImageAndTextCell *cell = [[BFImageAndTextCell alloc] init];
		[cell setEditable:NO];
		[cell setDisplayImageSize:NSMakeSize(23.0f,23.0f)];
		[col  setDataCell:cell];
		[cell release];
		[serverListView setDoubleAction:@selector(doubleClicked:)];
	}
	return self;
}

- (void)dealloc
{
	[serverInfoOutput release];
	serverInfoOutput = nil;
	[taskList release];
	taskList = nil;
	[serverList release];
	serverList = nil;
	[super dealloc];
}

- (IBAction)clicked:(id)sender
{
	NSDictionary *selected = [self selectedServer];
	if( ! task && selected )
	{
		// TODO: Fetch game Name for game ID
		// NSString *gameName = [[[BFGamesManager sharedManager] gameInfo:[[selected objectForKey:@"gameID"] intValue]] objectForKey:@""];
		NSString *gameType = [[BFGamesManager sharedGamesManager] serverTypeForGID:[[selected objectForKey:@"gameID"] intValue]];
		[self getServerInfoWithIP:[selected objectForKey:@"ip"] andGameName:gameType];
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
	NSDictionary *selected = [self selectedServer];
	if( ! task && selected )
	{
		// TODO: Fetch game Name for game ID
		// NSString *gameName = [[[BFGamesManager sharedManager] gameInfo:[[selected objectForKey:@"gameID"] intValue]] objectForKey:@""];
		NSString *gameType = [[BFGamesManager sharedManager] serverTypeForGID:[[selected objectForKey:@"gameID"] intValue]];
		[self getServerInfoWithIP:[selected objectForKey:@"ip"] andGameName:gameType];
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
	for(NSDictionary *dict in serverList)
	{
		[taskList addObject:dict];
	}
	[self nextTask];
}

- (IBAction) doubleClicked:(id)sender
{
	NSDictionary *dict = [self selectedServer];
	[[BFGamesManager sharedGamesManager] launchGame:[[dict objectForKey:@"gameID"] intValue] withAddress:[dict objectForKey:@"ip"]];
}

#pragma mark - Getting server information

- (void) processStarted
{
}

- (void) processFinished
{
	id serverInfo = [serverInfoOutput propertyList];
	if ([serverInfo isKindOfClass:[NSDictionary class]]) 
	{
		if(	! [[serverInfo objectForKey:@"status"] isEqualToString:@"UP"] )
		{
			NSString *ip = [serverInfo objectForKey:@"address"];
			for(NSMutableDictionary *game in serverList)
			{
				if( [[game objectForKey:@"ip"] isEqualToString:ip] )
				{
					[game setObject:@"(Offline)" forKey:@"name"];
					[serverListView reloadData];
					break; // not done here
				}
			}
			[serverListView reloadData];
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
		//NSString *name = stringFromQuakeString([serverInfo objectForKey:@"name"]);
		//NSString *name = [BFAppSupport stripQuakeColorCodes:[serverInfo objectForKey:@"name"]];
		NSString *name = nil;
		NSString *ip   = [serverInfo objectForKey:@"address"];
		if( name )
		{
			for(NSMutableDictionary *game in serverList)
			{
				if( [[game objectForKey:@"ip"] isEqualToString:ip] )
				{
					[game setObject:name forKey:@"name"];
					[serverListView reloadData];
					//[[delegate drawer] handleOutput:serverInfoOutput];
					//[[delegate drawer] appendOutput:serverInfoOutput];
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
		NSDictionary *dict = [taskList lastObject];
		[self getServerInfoWithIP:[dict objectForKey:@"ip"] andGameName:[[BFGamesManager sharedManager] serverTypeForGID:[[dict objectForKey:@"gameID"] intValue]]];
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
	task = [[TaskWrapper alloc] initWithController:self arguments:arguments];
	[task startProcess:qstatPath];
	[arguments release];
}

- (NSDictionary *)selectedServer
{
	unsigned int activeRow = [self activeRow];
	if( activeRow < [serverList count] )
	{
		return [serverList objectAtIndex:activeRow];
	}
	return nil;
}

- (int)activeRow 
{
	int selRow    = [serverListView selectedRow];
	int clickRow  = [serverListView clickedRow];
	
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


- (void)setServerListReference:(NSArray *)servers
{
	[serverList release];
	serverList = [servers retain];
}

- (BOOL) validateMenuItem:(NSMenuItem *)anItem
{
	return YES;
}

#pragma mark -
#pragma mark EXOutlineView datasource

- (id) outlineView:(NSOutlineView *)olView child:(int)index ofItem:(id)item {
	return [serverList objectAtIndex:index];
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

- (int)outlineView:(NSOutlineView *)anOutlineView numberOfChildrenOfItem:(id)item {
	return [serverList count];
}

- (id)outlineView:(NSOutlineView *)anOutlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	//return [item objectForKey:@"name"];
	if(! item ) return nil;
	NSString *name = [item objectForKey:@"name"];
	if( ! name )
		name = [item objectForKey:@"ip"];
	return name;
}

- (id)outlineView:(NSOutlineView *)anOutlineView itemForPersistentObject:(id)object
{
	return nil;
}

- (id)outlineView:(NSOutlineView *)anOutlineView persistentObjectForItem:(id)item
{
	if(! item ) return nil;
	NSString *name = [item objectForKey:@"name"];
	if( ! name )
		name = [item objectForKey:@"ip"];
	return name;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	// return [outlineView isExpandable:item];
	return NO;
}

- (void)outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if( cell )
    {
		unsigned int gameID = [[item objectForKey:@"gameID"] intValue];
		NSString *name = [item objectForKey:@"name"];
		if( gameID != 0 )
		{
			[(BFImageAndTextCell *)cell setImage:[[BFGamesManager sharedManager] imageForGame:gameID]];
		}
		else 
		{
			[(BFImageAndTextCell *)cell setImage:[NSImage imageNamed:@"blackfire"]];
		}
		if( name && [name length] > 0 )
		{
			[(BFImageAndTextCell *)cell setCellStatusString:[item objectForKey:@"ip"]];
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
	return 24.0f;
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
	return NO;
}

@end
