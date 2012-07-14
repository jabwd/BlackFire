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
{
	NSMutableArray		*_runningGames;
	NSMutableArray		*_missingIcons;
	NSMutableArray		*_knownMissing;
	NSString			*_cachesPath;
	
	NSMutableDictionary *_gameIcons;
	
	BFDownload *_download;
}

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
		
		_cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	}
	return self;
}

- (void)dealloc
{
	_gameIcons = nil;
	_cachesPath = nil;
	_missingIcons = nil;
	_runningGames = nil;
	_knownMissing = nil;
}

- (void)reloadData
{
	_macGames		= [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MacGames" ofType:@"plist"]];
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:BFCustomMacGamesList];
	if( dict )
		[_macGames addEntriesFromDictionary:dict];
}

#pragma mark - Xfire games


- (NSInteger)gamesVersion
{
	return [_games[@"XfireGamesVersion"] integerValue];
}

/*
 * Checks whether we need to update the current game definitions and 
 * downloads the new definitions if needed.
 */
- (void)checkForUpdatesAndUpdate
{
	
}




- (NSUInteger)gamesCount
{
	return [_games count];
}

- (NSDictionary *)gameAtIndex:(NSInteger)index
{
	NSArray *keys = [_games allKeys];
	return _games[keys[index]];
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
	NSString *finalPath = [[NSString alloc] initWithFormat:@"%@/com.exurion.BlackFire",_cachesPath];
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
	
	NSString *cacheFile = [NSString stringWithFormat:@"%@/%u.png",finalPath,[game unsignedIntValue]];
	
	[[NSFileManager defaultManager] moveItemAtPath:path toPath:cacheFile error:nil];
	
	if( [_delegate respondsToSelector:@selector(gameIconDidDownload)] )
		[_delegate gameIconDidDownload];
	
	[_missingIcons removeObjectAtIndex:0];
	
	_download = nil;
	finalPath = nil;
	
	[self downloadNextMissingIcon];
}

- (void)downloadNextMissingIcon
{
	if( _download )
	{
		_download = nil;
	}
	if( [_missingIcons count] < 1 )
	{
		return; // break the cycle
	}
	NSNumber *game = _missingIcons[0];
	
	_download = [BFDownload imageDownload:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.exurion.com/xfire/icons/%u.png",[game unsignedIntValue]]] withDelegate:self];
	_download.context = game;
	
}

- (NSImage *)imageForGame:(unsigned int)gameID
{
	if( gameID > 0 )
	{
		NSString *key = [[NSString alloc] initWithFormat:@"%u",gameID];
		NSImage *image = _gameIcons[key];
		if( ! image )
		{
			NSString *path = [[NSString alloc] initWithFormat:@"%@/com.exurion.BlackFire/%u.png",_cachesPath,gameID];
			NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
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
						[_missingIcons addObject:@(gameID)];
						if( ! _download )
							[self downloadNextMissingIcon];
					}
				}
			}
			else
			{
				// cache the image, as we actually have an image! yay :D
				_gameIcons[key] = image;
				[image setScalesWhenResized:true];
				return image;
			}
			
		}
		[image setScalesWhenResized:true];
		
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
		new[detectionKey] = newGame;
		NSDictionary *old = [[NSUserDefaults standardUserDefaults] objectForKey:BFCustomMacGamesList];
		if( old )
			[new addEntriesFromDictionary:old];
		[[NSUserDefaults standardUserDefaults] setObject:new forKey:BFCustomMacGamesList];
		
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

	output = _macGames[applicationInfo.bundleIdentifier];
	if( !output )
		output = _macGames[applicationInfo.localizedName];
	
	if( !output )
	{
		NSString *parentFolderName = [[[applicationInfo.executableURL relativePath] stringByDeletingLastPathComponent] lastPathComponent];
		output = _macGames[parentFolderName];
	}
	return [output[@"gameID"] intValue];
}

- (unsigned int)gameIDForApplicationDict:(NSDictionary *)applicationInfo
{
	NSDictionary *output = nil;
	output = _macGames[applicationInfo[@"NSApplicationBundleIdentifier"]];
	if( !output )
		output = _macGames[applicationInfo[@"NSApplicationName"]];
	
	if( !output )
	{
		NSString *parentFolderName = [[applicationInfo[@"NSApplicationPath"] stringByDeletingLastPathComponent] lastPathComponent];
		output = _macGames[parentFolderName];
	}
	return [output[@"gameID"] intValue];
}

- (void)reCheckRunningGames
{
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
	if( gameInfo && [[NSUserDefaults standardUserDefaults] boolForKey:BFDetectGames] )
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
		[_delegate gameDidLaunch:[_runningGames[0] intValue]];
	}
}

#pragma mark - Launching games

- (NSDictionary *)macGameInfoForGID:(unsigned int)gameID
{
	for(NSDictionary *value in [_macGames allValues])
	{
		if( [value[@"gameID"] intValue] == gameID )
		{
			return value;
		}
	}
	return nil;
}


- (void)launchGame:(unsigned int)gameID withAddress:(NSString *)address{
	NSDictionary *gameInfo = [self macGameInfoForGID:gameID];
	
	NSString  *gameName   = gameInfo[@"AppName"];
	NSArray   *arguments  = gameInfo[@"arguments"];
	if(       gameName    == nil ) return;
	
	if(arguments && [arguments count] != 0)
	{
		if( [arguments[0] length] > 0 && [arguments[0] isEqualToString:@"NSServices"]){
			if(address)
			{
				NSPasteboard *paste = [NSPasteboard pasteboardWithName:@"paste"];
				[paste declareTypes: @[NSStringPboardType] owner: nil];
				[paste setString:address forType:NSStringPboardType];
				NSString *str = [NSString stringWithFormat:@"%@/Connect To Server", gameName];
				NSPerformService(str, paste);
			}
		}
		else {
			NSMutableArray *arguements = [[NSMutableArray alloc] init];
			
			if(address && [arguments[0] length] > 0 )
			{
				[arguements addObject:arguments[0]];
				[arguements addObject:address];
			}
			[self startGame:gameName withArguments:arguements];
		}
	}
	else
		[[NSWorkspace sharedWorkspace] launchApplication:gameName];
}

- (NSString *)serverTypeForGID:(unsigned int)gid
{
    NSDictionary *dict = _macGames[@"serverTypes"];
	return dict[[NSString stringWithFormat:@"%u",gid]];
}

- (void)launchGame:(unsigned int)gameID
{
    NSDictionary *macGameInfo = [self macGameInfoForGID:gameID];
    NSArray *arg = macGameInfo[@"arguments"];
    if( [arg count] > 0 )
    {
        // ask for the user's ip address
        return;
    }
    NSString *gameName = macGameInfo[@"AppName"];
	[[NSWorkspace sharedWorkspace] launchApplication:gameName];
	
	// try launching with .app extension
	//[[NSWorkspace sharedWorkspace] launchApplication:[NSString stringWithFormat:@"%@.app",gameName]];
}

- (NSArray *)getLaunchArgumentsForMacGame:(NSString *)game
{
    return _macGames[game][@"arguments"];
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
