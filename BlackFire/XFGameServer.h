//
//  XFGameServer.h
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//
//	Don't expect this to be a magic class that hosts a game server
//	this class is just another "data" type like XFFriend that stores
//	the user's favorite game servers

#import <Foundation/Foundation.h>

@interface XFGameServer : NSObject
{
	NSString *_name;
	
	unsigned int	_IPAddress;
	unsigned short	_port;
	unsigned int	_gameID;
}

@property (nonatomic, retain) NSString *name;

@property (nonatomic, assign) unsigned int IPAddress;
@property (nonatomic, assign) unsigned short port;
@property (nonatomic, assign) unsigned int gameID;

- (NSString *)address;

@end
