//
//  XFGamesManager.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/20/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//

#import "XFGamesManager.h"

#define GAMESFILE_NAME @"Games"

// modify these if your file is using different key/value pairs
NSString *XFLongNameKey		= @"LongName";
NSString *XFShortNameKey	= @"ShortName";
NSString *XFGameIDKey		= @"ID";

static XFGamesManager *sharedGameManager = nil;

@implementation XFGamesManager


+ (id)sharedGamesManager
{
	if( ! sharedGameManager )
		sharedGameManager = [[[self class] alloc] init];
	return sharedGameManager;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_games = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:GAMESFILE_NAME ofType:@"plist"]];
		if( ! _games )
		{
			NSLog(@"*** Unable to open %@.plist",GAMESFILE_NAME);
			self = nil;
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	_games = nil;
}

- (XFGame *)gameForGameID:(NSUInteger)gameID
{
	NSString *key = [[NSString alloc] initWithFormat:@"%lu",gameID];
	XFGame *game = [[XFGame alloc] init];
	NSDictionary *info = _games[key];
	if( info )
	{
		game.longName	= info[XFLongNameKey];
		game.shortName	= info[XFShortNameKey];
		game.gameID		= (unsigned int)gameID;
	}
	else
	{
		NSLog(@"*** Unknown gameID: %lu",(unsigned long)gameID);
		game.longName	= @"Unknown game";
		game.gameID		= -1;
		game.shortName	= @"-1";
	}
	
	return game;
}

- (NSString *)longNameForGameID:(NSUInteger)gameID
{
	return [self gameForGameID:gameID].longName;
}

- (NSString *)shortNameForGameID:(NSUInteger)gameID
{
	return [self gameForGameID:gameID].shortName;
}

@end
