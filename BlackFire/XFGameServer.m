//
//  XFGameServer.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "XFGameServer.h"
#import "XfireKit.h"

@implementation XFGameServer

@synthesize name		= _name;

@synthesize IPAddress	= _IPAddress;
@synthesize port		= _port;
@synthesize gameID		= _gameID;

- (NSString *)description
{
	return [NSString stringWithFormat:@"[Xfire game server IP='%@' Port='%lu' GameID='%lu']",NSStringFromIPAddress(_IPAddress),_port,_gameID];
}

- (NSString *)address
{
	if( _IPAddress == 0 )
		return @"No IP Address";
	return [NSString stringWithFormat:@"%@:%lu",NSStringFromIPAddress(_IPAddress),_port];
}

@end
