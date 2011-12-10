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
		_missingIcons	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[_missingIcons release];
	_missingIcons = nil;
	[_runningGames release];
	_runningGames = nil;
	[_macGames release];
	_macGames = nil;
	[super dealloc];
}

#pragma mark - Xfire games

- (void)download:(BFDownload *)download didFailWithError:(NSError *)error
{
	[self downloadNextMissingIcon];
	
	NSLog(@"*** Game icon download failed with error: %@",error);
}

- (void)download:(BFDownload *)download didFinishWithPath:(NSString *)path
{
	NSNumber *game = (NSNumber *)download.context;
	if( ![game isKindOfClass:[NSNumber class]] )
	{
		NSLog(@"*** Context of BFDownload is invalid, cannot move image file");
		return;
	}
	NSString *finalPath = [NSString stringWithFormat:@"%@/%u.png",[[NSBundle mainBundle] resourcePath],[game unsignedIntValue]];
	
	NSError *error = nil;
	[[NSFileManager defaultManager] moveItemAtPath:path toPath:finalPath error:&error];
	
	if( error )
	{
		NSLog(@"*** An error occured while moving %@ to %@\n%@",path,finalPath,error);
	}
	
	if( [_delegate respondsToSelector:@selector(gameIconDidDownload)] )
		[_delegate gameIconDidDownload];
	
	[_missingIcons removeObjectAtIndex:0];
	
	[_download release];
	_download = nil;
	
	[self downloadNextMissingIcon];
}

- (void)downloadNextMissingIcon
{
	if( _download )
	{
		[_download release];
		_download = nil;
	}
	if( [_missingIcons count] < 1 )
	{
		NSLog(@"Done downloading all the game icons needed for this session.");
		return; // break the cycle
	}
	NSNumber *game = [[_missingIcons objectAtIndex:0] retain];
	
	_download = [[BFDownload imageDownload:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.exurion.com/xfire/icons/%u.png",[game unsignedIntValue]]] withDelegate:self] retain];
	_download.context = game;
	
	[game release];
}

- (NSImage *)imageForGame:(unsigned int)gameID
{
	if( gameID > 0 )
	{
		NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"%u",gameID]];
		if( ! image )
		{
			image = [NSImage imageNamed:@"-1"];
			
			// found a missing icon, should we add it or not ?
			BOOL found = false;
			for(NSNumber *game in _missingIcons)
			{
				if( [game unsignedIntValue] == gameID )
				{
					found = true;
					break;
				}
			}
			if( ! found )
			{
				[_missingIcons addObject:[NSNumber numberWithUnsignedInt:gameID]];
				if( ! _download )
					[self downloadNextMissingIcon];
			}
		}
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
