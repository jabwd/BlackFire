//
//  BFGamesManager.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "BFGamesManager.h"
#import "BFProcessInformation.h"
#import "BFDefaults.h"

@implementation BFGamesManager

@synthesize delegate	= _delegate;
@synthesize macGames	= _macGames;

- (id)init
{
	if( (self = [super init]) )
	{
		_macGames		= [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MacGames" ofType:@"plist"]];
		NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:BFCustomMacGamesList];
		if( dict )
			[_macGames addEntriesFromDictionary:dict];
		_runningGames	= [[NSMutableArray alloc] init];
		_missingIcons	= [[NSMutableArray alloc] init];
		_knownMissing	= [[NSMutableArray alloc] init];
		_gameIcons		= [[NSMutableDictionary alloc] init];
		
		_cachesPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] retain];
	}
	return self;
}

- (void)dealloc
{
	[_gameIcons release];
	_gameIcons = nil;
	[_cachesPath release];
	_cachesPath = nil;
	[_missingIcons release];
	_missingIcons = nil;
	[_runningGames release];
	_runningGames = nil;
	[_macGames release];
	_macGames = nil;
	[_knownMissing release];
	_knownMissing = nil;
	[super dealloc];
}

- (void)reloadData
{
	[_macGames release];
	_macGames		= [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MacGames" ofType:@"plist"]];
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:BFCustomMacGamesList];
	if( dict )
		[_macGames addEntriesFromDictionary:dict];
}

#pragma mark - Xfire games

- (NSUInteger)gamesCount
{
	return [_games count];
}

- (NSDictionary *)gameAtIndex:(NSInteger)index
{
	NSArray *keys = [_games allKeys];
	return [_games objectForKey:[keys objectAtIndex:index]];
}

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
	BOOL isDir = false;
	NSString *finalPath = [[NSString alloc] initWithFormat:@"%@/com.jabwd.BlackFire",_cachesPath];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:finalPath isDirectory:&isDir] )
	{
		NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:finalPath withIntermediateDirectories:true attributes:nil error:&error];
		if( error )
		{
			NSLog(@"*** Cannot create cache folder directory");
		}
	}
	
	// validate the image
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
	if( !image )
	{
		NSLog(@"*** Image for %@ could not be downloaded",game);
		[_knownMissing addObject:game];
	}
	[image release];
	
	NSString *cacheFile = [NSString stringWithFormat:@"%@/%u.png",finalPath,[game unsignedIntValue]];
	
	[[NSFileManager defaultManager] moveItemAtPath:path toPath:cacheFile error:nil];
	
	if( [_delegate respondsToSelector:@selector(gameIconDidDownload)] )
		[_delegate gameIconDidDownload];
	
	[_missingIcons removeObjectAtIndex:0];
	
	[_download release];
	_download = nil;
	[finalPath release];
	finalPath = nil;
	
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
		NSString *key = [[NSString alloc] initWithFormat:@"%u",gameID];
		NSImage *image = [_gameIcons objectForKey:key];
		if( ! image )
		{
			NSString *path = [[NSString alloc] initWithFormat:@"%@/com.jabwd.BlackFire/%u.png",_cachesPath,gameID];
			NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
			if( ! image )
			{
				//image = [NSImage imageNamed:@"xfire"];
				
				// check if we know the game
				if( [self gameForGameID:gameID].gameID != -1 )
				{
					
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
					for(NSNumber *game in _knownMissing)
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
			}
			else
			{
				// cache the image, as we actually have an image! yay :D
				[_gameIcons setObject:image forKey:key];
				[path release];
				[image setScalesWhenResized:true];
				[key release];
				return image;
			}
			
			[path release];
		}
		[image setScalesWhenResized:true];
		
		[key release];
		if( ! image )
		{
			image = [NSImage imageNamed:@"xfire"];
		}
		return image;
	}
	NSImage *tmp = [NSImage imageNamed:@"xfire"];
	[tmp setScalesWhenResized:true];
	return tmp;
}

#pragma mark - Mac Games

- (void)addMacGame:(NSDictionary *)newGame forKey:(NSString *)detectionKey
{
	if( newGame && detectionKey )
	{
		NSMutableDictionary *new = [[NSMutableDictionary alloc] init];
		[new setObject:newGame forKey:detectionKey];
		NSDictionary *old = [[NSUserDefaults standardUserDefaults] objectForKey:BFCustomMacGamesList];
		if( old )
			[new addEntriesFromDictionary:old];
		[[NSUserDefaults standardUserDefaults] setObject:new forKey:BFCustomMacGamesList];
		[new release];
		
		[self reloadData];
	}
}

- (unsigned int)gameIDForApplication:(NSRunningApplication *)applicationInfo
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

	output = [_macGames objectForKey:applicationInfo.bundleIdentifier];
	if( !output )
		output = [_macGames objectForKey:applicationInfo.localizedName];
	
	if( !output )
	{
		NSString *parentFolderName = [[[applicationInfo.executableURL relativePath] stringByDeletingLastPathComponent] lastPathComponent];
		output = [_macGames objectForKey:parentFolderName];
	}
	return [[output objectForKey:@"gameID"] intValue];
}

- (unsigned int)gameIDForApplicationDict:(NSDictionary *)applicationInfo
{
	NSDictionary *output = nil;
	output = [_macGames objectForKey:[applicationInfo objectForKey:@"NSApplicationBundleIdentifier"]];
	if( !output )
		output = [_macGames objectForKey:[applicationInfo objectForKey:@"NSApplicationName"]];
	
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
	//NSArray *runningApplications = [[NSWorkspace sharedWorkspace] launchedApplications];
	// Fuck leopard, we are not supporting PPC anyways.
	NSArray *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
	for(NSRunningApplication *app in runningApplications)
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
	NSNumber *gameInfo = [NSNumber numberWithInt:[self gameIDForApplicationDict:userInfo]];
	if( gameInfo )
	{
		[_runningGames addObject:gameInfo];
		[_delegate     gameDidLaunch:[gameInfo intValue]];
	}
}

- (void)applicationDidExit:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *gameInfo = [NSNumber numberWithInt:[self gameIDForApplicationDict:userInfo]];
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

#pragma mark - Launching games

- (NSDictionary *)macGameInfoForGID:(unsigned int)gameID
{
	for(NSDictionary *value in [_macGames allValues])
	{
		if( [[value objectForKey:@"gameID"] intValue] == gameID )
		{
			return value;
		}
	}
	return nil;
}


- (void)launchGame:(unsigned int)gameID withAddress:(NSString *)address{
	NSDictionary *gameInfo = [self macGameInfoForGID:gameID];
	
	NSString  *gameName   = [gameInfo objectForKey:@"AppName"  ];
	NSArray   *arguments  = [gameInfo objectForKey:@"arguments"];
	if(       gameName    == nil ) return;
	
	if(arguments && [arguments count] != 0)
	{
		if( [[arguments objectAtIndex:0] length] > 0 && [[arguments objectAtIndex:0] isEqualToString:@"NSServices"]){
			if(address)
			{
				NSPasteboard *paste = [NSPasteboard pasteboardWithName:@"paste"];
				[paste declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: nil];
				[paste setString:address forType:NSStringPboardType];
				NSString *str = [NSString stringWithFormat:@"%@/Connect To Server", gameName];
				NSPerformService(str, paste);
			}
		}
		else {
			NSMutableArray *arguements = [[NSMutableArray alloc] init];
			
			if(address && [[arguments objectAtIndex:0] length] > 0 )
			{
				[arguements addObject:[arguments objectAtIndex:0]];
				[arguements addObject:address];
			}
			[self startGame:gameName withArguments:arguements];
			[arguements release];
		}
	}
	else
		[[NSWorkspace sharedWorkspace] launchApplication:gameName];
}

- (NSString *)serverTypeForGID:(unsigned int)gid
{
    NSDictionary *dict = [_macGames objectForKey:@"serverTypes"];
	return [dict objectForKey:[NSString stringWithFormat:@"%u",gid]];
}

- (void)launchGame:(unsigned int)gameID
{
    NSDictionary *macGameInfo = [self macGameInfoForGID:gameID];
    NSArray *arg = [macGameInfo objectForKey:@"arguments"];
    if( [arg count] > 0 )
    {
        // ask for the user's ip address
        return;
    }
    NSString *gameName = [macGameInfo objectForKey:@"AppName"];
	[[NSWorkspace sharedWorkspace] launchApplication:gameName];
	
	// try launching with .app extension
	//[[NSWorkspace sharedWorkspace] launchApplication:[NSString stringWithFormat:@"%@.app",gameName]];
}

- (NSArray *)getLaunchArgumentsForMacGame:(NSString *)game
{
    return [[_macGames objectForKey:game] objectForKey:@"arguments"];
}

- (BOOL)startGame:(NSString *)game withArguments:(NSArray *)arguments
{
	NSMutableString *fullName = [NSMutableString stringWithString:game];
	[fullName appendString:@".app"];
	NSString *fullAppPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:fullName];
	if( !fullAppPath ) 
	{
		return NO;
	}
	NSMutableString *path = [NSMutableString stringWithString:fullAppPath];
	[path appendString:@"/Contents/MacOS/"];
	[path appendString:game];
	[NSTask launchedTaskWithLaunchPath:path arguments:arguments];
	return TRUE; //TODO!!
}


@end
