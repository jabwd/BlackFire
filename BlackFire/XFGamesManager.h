//
//  XFGamesManager.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/20/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//
//  As this class does not require an XFSession, a shared instance is optional

#import <Foundation/Foundation.h>
#import "XFGame.h"

extern NSString *XFLongNameKey;
extern NSString *XFShortNameKey;
extern NSString *XFGameIDKey;

@interface XFGamesManager : NSObject
{
	NSMutableDictionary *_games;
}

+ (id)sharedGamesManager;

- (XFGame *)gameForGameID:(unsigned int)gameID;

- (NSString *)longNameForGameID:(unsigned int)gameID;
- (NSString *)shortNameForGameID:(unsigned int)gameID;

@end
