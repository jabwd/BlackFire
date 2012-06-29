//
//  XfireKit.h
//  BlackFire
//
//  Created by Antwan van Houdt on 8/10/10.
//  Copyright 2010 Excurion. All rights reserved.
//	Special thanks to Archon ( macfire.org ), this framework
//	is based on his awesome work.
//
// This file contains some functions that are very useful
// anywhere inside the XfireKit framework
//

#import <Foundation/Foundation.h>
#import "NSData_XfireAdditions.h"

#define XFIRE_ADDRESS @"cs.xfire.com"
#define XFIRE_PORT		25999

static inline unsigned int IPAddressFromNSString(NSString *address)
{
	unsigned int ipAddress = 0;
	if( address && [address length] ) 
	{
		NSArray *components = [address componentsSeparatedByString:@"."];
		if( [components count] == 4 ) 
		{
			ipAddress = (([components[0] intValue] << 24) |
						 ([components[1] intValue] << 16) |
						 ([components[2] intValue] <<  8) |
						 ([components[3] intValue]));
		} 
		else 
		{
			NSLog(@"*** Incorrect IP Address string, unable to create IP Address integer '%@'",address);
		}
	
		return NSSwapHostIntToLittle(ipAddress);
	}
	else
		NSLog(@"*** NIL IP Address string");
	return 0;
}

static inline NSString *NSStringFromIPAddress(NSUInteger address)
{
	address = NSSwapHostLongToLittle(address);
	unsigned char t1, t2, t3, t4;
	
	t1 = (address >> 24) & 0xFF;
	t2 = (address >> 16) & 0xFF;
	t3 = (address >>  8) & 0xFF;
	t4 = (address      ) & 0xFF;
	
	return [NSString stringWithFormat:@"%hu.%hu.%hu.%hu", (unsigned short)t1, (unsigned short)t2, (unsigned short)t3, (unsigned short)t4];
}

static inline NSNumber *NSNumberFromIPAddress(NSUInteger address)
{
	return @(address);
}

static inline NSNumber *NSNumberFromPort(UInt16 port)
{
	return @(port);
}

/*static inline NSString *XFSaltString() 
{
	return [[[NSString stringWithFormat:@"%d", rand()] dataUsingEncoding:NSUTF8StringEncoding] sha1HexHash];
}*/

static inline NSInteger createHashCRC32(NSData *hashData)
{
	NSInteger crc32 = 0;
	
	if( [hashData length] ) 
	{
		NSUInteger p_len = [hashData length];
		const void *p_data = [hashData bytes];
		
		crc32 = 0xffffffff;
		
		NSInteger i;
		
		for(i = 0; i < p_len; i++) 
		{
			crc32 = (crc32 >> 8) ^ crc32table[((unsigned char *)p_data)[i] ^ (crc32 & 0x000000ff)];
		}
		
		return ~crc32;
	}
	return crc32;
}

/*static inline NSData *XFMonikerFromSessionIDAndSalt(NSData *sessionID, NSString *salt)
{
	NSString *stringRep = [[sessionID stringRepresentation] stringByAppendingString:salt];
	NSData *moniker = [[stringRep dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
	return moniker;
}*/
// EOF
