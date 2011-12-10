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
	NSString			*_cachesPath;
	
	BFDownload *_download;
	
	id <BFGameDetectionDelegate> _delegate;
}

@property (assign) id <BFGameDetectionDelegate> delegate;

//----------------------------------------------------------------------------
// Xfire games

- (NSImage *)imageForGame:(unsigned int)gameID;
- (void)downloadNextMissingIcon;


//-----------------------------------------------------------------------------
// Mac games

- (unsigned int)gameIDForApplication:(NSDictionary *)applicationInfo;

- (void)startMonitoring;
- (void)stopMonitoring;
@end
