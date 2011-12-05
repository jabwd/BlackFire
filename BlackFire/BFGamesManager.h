//
//  BFGamesManager.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/28/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFGamesManager.h"

@protocol BFGameDetectionDelegate <NSObject>

- (void)gameDidLaunch:(unsigned int)gameID;
- (void)gameDidTerminate:(unsigned int)gameID;

@end

@interface BFGamesManager : XFGamesManager
{
	NSMutableDictionary *_macGames;
	NSMutableArray		*_runningGames;
	
	id <BFGameDetectionDelegate> _delegate;
}

@property (assign) id <BFGameDetectionDelegate> delegate;

//----------------------------------------------------------------------------
// Xfire games

- (NSImage *)imageForGame:(NSUInteger)gameID;


//-----------------------------------------------------------------------------
// Mac games

- (unsigned int)gameIDForApplication:(NSDictionary *)applicationInfo;

- (void)startMonitoring;
- (void)stopMonitoring;
@end
