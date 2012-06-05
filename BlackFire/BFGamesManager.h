//
//  BFGamesManager.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFGamesManager.h"
#import "BFDownload.h"

@protocol BFGameDetectionDelegate <NSObject>

- (void)gameDidLaunch:(unsigned int)gameID;
- (void)gameDidTerminate:(unsigned int)gameID;
- (void)gameIconDidDownload; // used for reloading the data on the tableview

@end

@interface BFGamesManager : XFGamesManager <BFDownloadDelegate>
{
	NSMutableDictionary *_macGames;
	NSMutableArray		*_runningGames;
	NSMutableArray		*_missingIcons;
	NSMutableArray		*_knownMissing;
	NSString			*_cachesPath;
	
	NSMutableDictionary *_gameIcons;
	
	BFDownload *_download;
	
	id <BFGameDetectionDelegate> _delegate;
}

@property (assign) id <BFGameDetectionDelegate> delegate;
@property (readonly) NSMutableDictionary *macGames;

- (void)reloadData;

//----------------------------------------------------------------------------
// Xfire games

- (NSImage *)imageForGame:(unsigned int)gameID;
- (void)downloadNextMissingIcon;

- (NSUInteger)gamesCount;
- (NSDictionary *)gameAtIndex:(NSInteger)index;

- (NSInteger)gamesVersion;
- (void)checkForUpdatesAndUpdate;


//-----------------------------------------------------------------------------
// Mac games

- (void)addMacGame:(NSDictionary *)newGame forKey:(NSString *)detectionKey;
- (unsigned int)gameIDForApplication:(NSRunningApplication *)applicationInfo;
- (unsigned int)gameIDForApplicationDict:(NSDictionary *)applicationInfo;

- (void)reCheckRunningGames;
- (void)startMonitoring;
- (void)stopMonitoring;


//----------------------------------------------------------------------------
// Launching games

- (NSDictionary *)macGameInfoForGID:(unsigned int)gameID;
- (void)launchGame:(unsigned int)gameID withAddress:(NSString *)address;
- (NSString *)serverTypeForGID:(unsigned int)gid;
- (void)launchGame:(unsigned int)gameID;
- (NSArray *)getLaunchArgumentsForMacGame:(NSString *)game;
- (BOOL)startGame:(NSString *)game withArguments:(NSArray *)arguments;

@end
