//
//  XFGameServer.m
//  BlackFire
//
//  Created by Antwan van Houdt on 11/5/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//

#import "XFGameServer.h"
#import "XfireKit.h"

NSString *XFGameServerPingKey = @"ping";
NSString *XFGameServerNameKey = @"name";
NSString *XFGameServerXPKey	  = @"xp";

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
	
	[_raw release];
	_raw = [raw retain];
}

- (NSString *)playerString
{
	if( _raw && self.online )
	{
		return [NSString stringWithFormat:@"%@/%@",[_raw objectForKey:@"numplayers"],[_raw objectForKey:@"maxplayers"]];
	}
	return nil;
}

- (NSString *)map
{
	if( _raw && self.online )
	{
		return [_raw objectForKey:@"map"];
	}
	return nil;
}

- (NSString *)ping
{
	if( _raw && self.online )
	{
		return [_raw objectForKey:@"ping"];
	}
	return nil;
}

- (NSArray *)players
{
	if( _raw && self.online )
	{
		return [_raw objectForKey:@"players"];
	}
	return nil;
}

/*
 6/10/12 6:29:48.248 PM BlackFire: {
 address = "78.46.106.119:27960";
 gametype = silent;
 hostname = "78.46.106.119:27960";
 map = goldrush;
 maxplayers = 32;
 maxspectators = 0;
 name = "^7sKy^2-^7e^2.^7Begin^2ners XPS^7ave";
 numplayers = 22;
 numspectators = 0;
 ping = 23;
 players =     (
 {
 name = mateja;
 ping = 48;
 xp = 6;
 },
 {
 name = Alf;
 ping = 106;
 xp = 49479;
 },
 {
 name = "^ymysz";
 ping = 48;
 xp = 2203;
 },
 {
 name = "^0P^1i^0rinsessa";
 ping = 90;
 xp = 4250;
 },
 {
 name = "^6Jumal 10x ^7T^1NA";
 ping = 150;
 xp = 9262;
 },
 {
 name = "^!BATA";
 ping = 53;
 xp = 0;
 },
 {
 name = Genius667;
 ping = 50;
 xp = 13884;
 },
 {
 name = "^>$^43^>R^'*^>Sp^4I^>K";
 ping = 80;
 xp = 0;
 },
 {
 name = "^s.^9GoW^5*^sL^oamisz";
 ping = 85;
 xp = 2683;
 },
 {
 name = Shulc;
 ping = 54;
 xp = 25717;
 },
 {
 name = "^1LaLa";
 ping = 48;
 xp = 186550;
 },
 {
 name = Kosiarz;
 ping = 999;
 xp = 1552;
 },
 {
 name = "^8n^9Gag^8e";
 ping = 48;
 xp = 38093;
 },
 {
 name = harihari;
 ping = 62;
 xp = 65;
 },
 {
 name = xXfreeploXx;
 ping = 48;
 xp = 35;
 },
 {
 name = "^1EliTe^3T.rkisch^7Gamer";
 ping = 999;
 xp = 1243;
 },
 {
 name = ziplo;
 ping = 50;
 xp = 708;
 },
 {
 name = Apostol;
 ping = 61;
 xp = 6602;
 },
 {
 name = "TheSniper.pl";
 ping = 51;
 xp = 551;
 },
 {
 name = "^3Synio";
 ping = 95;
 xp = 25638;
 },
 {
 name = TacNac;
 ping = 116;
 xp = 59;
 },
 {
 name = "^0S^rh^0A^rB^0U^ru^0u";
 ping = 98;
 xp = 122778;
 }
 );
 retries = 0;
 status = UP;
 type = RWS;
 }

 */

@end
