//
//  BFGameServerInformation.m
//  BlackFire
//
//  Created by Antwan van Houdt on 6/10/12.
//  Copyright (c) 2012 Exurion. All rights reserved.
//

#import "BFGameServerInformation.h"
#import "XFGameServer.h"
#import "XFFriend.h"
#import "BFGamesManager.h"

/*
 * The implementation of this function can be found in the BFServerListController
 */
NSString *removeQuakeColorCodes(NSString *string);

static BFGameServerInformation *sharedInstance = nil;

@implementation BFGameServerInformation

@synthesize delegate = _delegate;

+ (id)sharedInformation
{
	if( ! sharedInstance )
	{
		sharedInstance = [[BFGameServerInformation alloc] init];
	}
	return sharedInstance;
}

- (id)init
{
	if( (self = [super init]) )
	{
		taskList			= [[NSMutableArray alloc] init];
		serverInfoOutput	= nil;
		current				= nil;
	}
	return self;
}

- (void)dealloc
{
	[taskList release];
	taskList = nil;
	[serverInfoOutput release];
	serverInfoOutput = nil;
	[task stopProcess];
	[task release];
	task = nil;
	[current release];
	current = nil;
	[super dealloc];
}

- (void)getInformationForFriend:(XFFriend *)friend
{
	XFGameServer *server = [[XFGameServer alloc] init];
	server.online		= false;
	server.IPAddress	= friend.gameIP;
	server.gameID		= friend.gameID;
	server.port			= friend.gamePort;
	[taskList addObject:server];
	[server release];
	if( ! serverInfoOutput )
		[self nextTask];
}



- (void)processStarted
{
}

- (void)processFinished
{
	if( ! serverInfoOutput )
		return;
	id serverInfo = [serverInfoOutput propertyList];
	if( [serverInfo isKindOfClass:[NSDictionary class]] ) 
	{
		/*if(	! [[serverInfo objectForKey:@"status"] isEqualToString:@"UP"] )
		{
			NSString *ip = [serverInfo objectForKey:@"address"];
			
			
			[serverInfoOutput release];
			serverInfoOutput = nil;*/
			/*
			 * Perform all the tasks set in our tasks Que
			 *//*
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
			// got server information.
		}*/
		current.raw = (NSDictionary *)serverInfo;
		if( [_delegate respondsToSelector:@selector(receivedInformationForServer:)] )
			[_delegate receivedInformationForServer:current];
		[current release];
		current = nil;
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
		if( ! serverInfoOutput )
			serverInfoOutput = [[NSMutableString alloc] init];
		
		XFGameServer *server = [taskList lastObject];
		[self getServerInfoWithIP:[server address] andGameName:[[BFGamesManager sharedGamesManager] serverTypeForGID:server.gameID]];
		[current release];
		current = [server retain];
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

@end
