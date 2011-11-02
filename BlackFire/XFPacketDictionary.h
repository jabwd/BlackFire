/*******************************************************************
	FILE:		XFPacketDictionary.h
	
	COPYRIGHT:
		Copyright 2007-2008, the MacFire.org team.
		Use of this software is governed by the license terms
		indicated in the License.txt file (a BSD license).
	
	DESCRIPTION:
		Represents a packet map in an XFPacket.  It's basically a
		wrapper around NSMutableDictionary that includes an array
		to order the keys.  It guarantees that keys are traversed in
		the same order as they are inserted.  This is protection against
		certain other implementations that my not work right (and a
		CYA in case order of attributes does matter).
	
	HISTORY:
		2008 04 06  Changed copyright to BSD license.
		2008 01 12  Added copyright notice.
		2007 11 14  Created.
*******************************************************************/

#import <Foundation/Foundation.h>

@class XFPacketAttributeValue;

/*
This is largely just a thin wrapper around NSMutableDictionary that can iterate
keys in insertion order.  This gets around the "problem" of the fact that
enumerating an NSDictionary does not guarantee a key order.
*/

@interface XFPacketDictionary : NSObject
{
	NSMutableArray      *_orderedKeys;
    NSMutableDictionary *_data;
}

+ (id)map;

- (void)setObject:(XFPacketAttributeValue *)value forKey:(id)aKey;
- (XFPacketAttributeValue *)objectForKey:(id)aKey;

- (NSEnumerator *)keyEnumerator;
- (NSArray *)allKeys;

- (NSUInteger)count;

@end
