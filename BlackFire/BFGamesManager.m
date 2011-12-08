//
//  BFGamesManager.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFGamesManager.h"
#import "BFProcessInformation.h"

@implementation BFGamesManager

@synthesize delegate = _delegate;

- (id)init
{
	if( (self = [super init]) )
	{
		_macGames		= [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MacGames" ofType:@"plist"]];
		_runningGames	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_runningGames release];
	_runningGames = nil;
	[_macGames release];
	_macGames = nil;
	[super dealloc];
}

#pragma mark - Xfire games

- (NSImage *)imageForGame:(NSUInteger)gameID
{
	if( gameID > 0 )
	{
		NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"%lu",gameID]];
		if( ! image )
			image = [NSImage imageNamed:@"-1"];
		[image setScalesWhenResized:true];
		return image;
	}
	NSImage *tmp = [NSImage imageNamed:@"-1"];
	[tmp setScalesWhenResized:true];
	return tmp;
}

#pragma mark - Mac Games

- (unsigned int)gameIDForApplication:(NSDictionary *)applicationInfo
{
	NSDictionary *output = nil;
	
	/*
	 2011-12-04 23:42:40.872 BlackFire[5736:403] ApplicationInfo: {
	 NSApplicationBundleIdentifier = "com.Mojang Specifications.Minecraft.Minecraft";
	 NSApplicationName = Minecraft;
	 NSApplicationPath = "/Applications/Minecraft.app";
	 NSApplicationProcessIdentifier = 5740;
	 NSApplicationProcessSerialNumberHigh = 0;
	 NSApplicationProcessSerialNumberLow = 1069317;
	 NSWorkspaceApplicationKey = "<NSRunningApplication: 0x7f7fa1467f90 (com.Mojang Specifications.Minecraft.Minecraft - 5740)>";
	 NSWorkspaceExitStatusKey = 0;
	 }
	 */
	
	//NSLog(@"ApplicationInfo: %@",applicationInfo);
	//[BFProcessInformation argumentsForProcess:[[applicationInfo objectForKey:@"NSApplicationProcessIdentifier"] intValue]];

	output = [_macGames objectForKey:[applicationInfo objectForKey:@"NSApplicationName"]];
	if( !output )
		output = [_macGames objectForKey:[applicationInfo objectForKey:@"NSApplicationBundleIdentifier"]];
	
	if( !output )
	{
		NSString *parentFolderName = [[[applicationInfo objectForKey:@"NSApplicationPath"] stringByDeletingLastPathComponent] lastPathComponent];
		output = [_macGames objectForKey:parentFolderName];
	}
	return [[output objectForKey:@"gameID"] intValue];
}

- (void)startMonitoring
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationDidLaunch:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(applicationDidExit:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	
	// Use Running applications for after Lion versions when leopard support will be dropped.
	NSArray *runningApplications = [[NSWorkspace sharedWorkspace] launchedApplications];
	for(NSDictionary *app in runningApplications)
	{
		NSNumber *gameInfo = [NSNumber numberWithInt:[self gameIDForApplication:app]];
		if( gameInfo )
		{
			[_runningGames addObject:gameInfo];
			[_delegate gameDidLaunch:[gameInfo intValue]];
		}
	}
}

- (void)stopMonitoring
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)applicationDidLaunch:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *gameInfo = [NSNumber numberWithInt:[self gameIDForApplication:userInfo]];
	if( gameInfo )
	{
		[_runningGames addObject:gameInfo];
		[_delegate     gameDidLaunch:[gameInfo intValue]];
	}
}

- (void)applicationDidExit:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *gameInfo = [NSNumber numberWithInt:[self gameIDForApplication:userInfo]];
	if( gameInfo && [_runningGames containsObject:gameInfo] )
	{
		[_runningGames removeObject:gameInfo];
		[_delegate gameDidTerminate:[gameInfo intValue]];
	}
	
	if( [_runningGames count] > 0 )
	{
		[_delegate gameDidLaunch:[[_runningGames objectAtIndex:0] intValue]];
	}
}

@end
