//
//  XFGamesManager.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/20/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//
//  As this class does not require an XFSession, a shared instance is optional
//	ITs generallay a good idea to subclass this class to suit your needs,
//	in this case blackfire is subclassing it to add support for NSImage ( appkit ) 
//	and game detection.

#import <Foundation/Foundation.h>
#import "XFGame.h"

extern NSString *XFLongNameKey;
extern NSString *XFShortNameKey;
extern NSString *XFGameIDKey;

@interface XFGamesManager : NSObject
{
	NSMutableDictionary *_games;
}

@property (unsafe_unretained, readonly) NSMutableDictionary *xfireGames;

+ (id)sharedGamesManager;

- (XFGame *)gameForGameID:(NSUInteger)gameID;

- (NSString *)longNameForGameID:(NSUInteger)gameID;
- (NSString *)shortNameForGameID:(NSUInteger)gameID;

@end
