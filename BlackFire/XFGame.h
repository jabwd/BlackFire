//
//  XFGame.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/20/11.
//  Copyright (c) 2011 Antwan van Houdt. All rights reserved.
//



@interface XFGame : NSObject
{
	NSString *_longName;
	NSString *_shortName;
	
	unsigned int _gameID;
}

@property (retain) NSString *longName;
@property (retain) NSString *shortName;
@property (assign) unsigned int gameID;


@end
