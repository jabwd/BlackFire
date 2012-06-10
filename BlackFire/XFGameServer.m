//
//  XFGameServer.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "XFGameServer.h"
#import "XfireKit.h"

/*
 * The implementation of this function can be found in the BFServerListController
 */
NSString *removeQuakeColorCodes(NSString *string);

@implementation XFGameServer

@synthesize name		= _name;

@synthesize IPAddress	= _IPAddress;
@synthesize port		= _port;
@synthesize gameID		= _gameID;
@synthesize online		= _online;

@synthesize raw = _raw;

- (void)dealloc
{
	[_raw release];
	_raw = nil;
	[_name release];
	_name = nil;
	[super dealloc];
}

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

#pragma mark - Processing the 'raw' data

- (void)setRaw:(NSDictionary *)raw
{
	if( raw && [[raw objectForKey:@"status"] isEqualToString:@"UP"] )
	{
		self.online = true;
	}
	
	if( raw )
	{
		if( [raw objectForKey:@"name"] )
		{
			self.name = removeQuakeColorCodes([raw objectForKey:@"name"]);
		}
	}
}

@end
