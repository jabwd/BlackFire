/*******************************************************************
	FILE:		XFPacketAttributeValue.m
	
	COPYRIGHT:
		Copyright 2007-2008, the MacFire.org team.
		Use of this software is governed by the license terms
		indicated in the License.txt file (a BSD license).
	
	DESCRIPTION:
		Represents a value in an XFPacketDictionary.  The only
		reason this class exists is to ensure that array types are
		correct when sent packets have empty arrays.  It's a CYA in
		case the Xfire master server requires correct types keys for
		attribute values.  Otherwise it is just a wrapper around
		the various Cocoa types that represent values in Xfire packets.
	
	HISTORY:
		2008 04 06  Changed copyright to BSD license.
		2008 01 12  Added copyright notice.
		2007 11 13  Created.
*******************************************************************/

#import "XFPacketAttributeValue.h"
#import "XFPacketDictionary.h"

@interface XFPacketAttributeValue (Private)
- (id)initWithValue:(id)aVal typeID:(int)tid arrayType:(int)atid;
+ (int)typeIDForObject:(id)obj;
+ (BOOL)keyIsNumber:(id)key;
@end


@implementation XFPacketAttributeValue

@synthesize value				= _value;
@synthesize typeID				= _typeID;
@synthesize arrayElementType	= _arrayElementType;

+ (id)attributeValueWithString:(NSString *)str
{
	return [[[XFPacketAttributeValue alloc]
		initWithValue:str
		typeID:XFPacketAttributeStringType
		arrayType:XFPacketAttributeInvalidType
		] autorelease];
}

+ (id)attributeValueWithInt:(unsigned int)val
{
	return [[[XFPacketAttributeValue alloc]
		initWithValue:[NSNumber numberWithUnsignedInt:val]
		typeID:XFPacketAttributeUInt32Type
		arrayType:XFPacketAttributeInvalidType
		] autorelease];
}

+ (id)attributeValueWithInt64:(unsigned long long)val
{
	return [[[XFPacketAttributeValue alloc]
		initWithValue:[NSNumber numberWithUnsignedLongLong:val]
		typeID:XFPacketAttributeUInt64Type
		arrayType:XFPacketAttributeInvalidType
		] autorelease];
}

+ (id)attributeValueWithByte:(unsigned char)val
{
	return [[[XFPacketAttributeValue alloc]
		initWithValue:[NSNumber numberWithUnsignedChar:val]
		typeID:XFPacketAttributeUInt8Type
		arrayType:XFPacketAttributeInvalidType
		] autorelease];
}

/*
 * For file transfers
 */
+ (id)attributeValueWithData:(NSData *)data
{
	return [[[XFPacketAttributeValue alloc] initWithValue:data typeID:XFPacketAttributeDataType arrayType:XFPacketAttributeInvalidType] autorelease];
}

+ (id)attributeValueWithNumber:(NSNumber *)nbr
{
	const char *octype = [nbr objCType];
	if( octype )
	{
		if( strcasecmp(octype,"i") == 0 )
		{
			return [[[XFPacketAttributeValue alloc]
				initWithValue:nbr
				typeID:XFPacketAttributeUInt32Type
				arrayType:XFPacketAttributeInvalidType
				] autorelease];
		}
	}
	return nil;
}

+ (id)attributeValueWithUUID:(NSData *)uuid
{
	if( [uuid length] == 16 )
	{
		return [[[XFPacketAttributeValue alloc]
			initWithValue:uuid
			typeID:XFPacketAttributeUUIDType
			arrayType:XFPacketAttributeInvalidType
			] autorelease];
	}
	return nil;
}

+ (id)attributeValueWithDid:(NSData *)did
{
	if( [did length] == 21 )
	{
		return [[[XFPacketAttributeValue alloc]
			initWithValue:did
			typeID:XFPacketAttributeDIDType
			arrayType:XFPacketAttributeInvalidType
			] autorelease];
	}
	return nil;
}

+ (id)attributeValueWithArray:(NSArray *)arr
{
	return [self attributeValueWithArray:arr emptyElementType:XFPacketAttributeStringType]; // default type for 0-element array
}

+ (id)attributeValueWithArray:(NSArray *)arr emptyElementType:(int)et
{
	// get the type of the first element, then check other elements
	NSUInteger cnt;
	
	//NSLog(@"attributeValueWithArray:%@ eET:%d",arr,et);
	
	cnt = [arr count];
	if( cnt == 0 )
	{
		return [[[XFPacketAttributeValue alloc]
			initWithValue:arr
			typeID:XFPacketAttributeArrayType
			arrayType:et
			] autorelease];
	}
	
	// Max array size supported by Xfire protocol is technically 65535, though in practice you would
	// blow the size off the entire packet if you did that.  We let the XFPacketGenerator deal with that since
	// we can't safely pick a size that won't have other problems.
	else if( cnt < 65536 )
	{
		int objType;
		NSUInteger i;
		id arrObj;
		
		arrObj = [arr objectAtIndex:0];
		objType = [XFPacketAttributeValue typeIDForObject:arrObj];
		if( ! [arrObj isKindOfClass:[XFPacketAttributeValue class]] )
		{
			NSLog(@"XFPacketAttributeValue: array element is not a valid class");
			return nil;
		}
		for( i = 1; i < cnt; i++ )
		{
			arrObj = [arr objectAtIndex:i];
			if( ! [arrObj isKindOfClass:[XFPacketAttributeValue class]] )
			{
				NSLog(@"XFPacketAttributeValue: array element is not a valid class");
				return nil;
			}
			if( objType != [XFPacketAttributeValue typeIDForObject:arrObj] )
			{
				// types don't match, abort
				NSLog(@"XFPacketAttributeValue: incompatible types while scanning array");
				return nil;
			}
		}
		
		//NSLog(@"objType %d, et = %d",objType,et);
		
		return [[[XFPacketAttributeValue alloc]
			initWithValue:arr
			typeID:XFPacketAttributeArrayType
			arrayType:objType
			] autorelease];
	}
	// else don't try
	
	return nil;
}

+ (id)attributeValueWithAttributeMap:(XFPacketDictionary *)map
{
	return [[[XFPacketAttributeValue alloc]
		initWithValue:map
		typeID:[self typeIDForObject:map]
		arrayType:XFPacketAttributeInvalidType
		] autorelease];
}

+ (int)typeIDForObject:(id)obj
{
	if( [obj isKindOfClass:[NSString class]] )
	{
		return XFPacketAttributeStringType;
	}
	else if( [obj isKindOfClass:[NSNumber class]] )
	{
		const char *octype = [((NSNumber*)obj) objCType];
		if( octype )
		{
			if( strcasecmp(octype,"i") == 0 )
			{
				return XFPacketAttributeUInt32Type;
			}
		}
	}
	else if( [obj isKindOfClass:[NSData class]] )
	{
		NSUInteger len = [((NSData*)obj) length];
		if( len == 16 )
		{
			return XFPacketAttributeUUIDType;
		}
		else if( len == 21 )
		{
			return XFPacketAttributeDIDType;
		}
	}
	else if( [obj isKindOfClass:[NSArray class]] )
	{
		return XFPacketAttributeArrayType;
	}
	else if( [obj isKindOfClass:[XFPacketDictionary class]] )
	{
		// check key domain
	/*	XFPacketDictionary *map = obj;
		id subkey;
		NSEnumerator *keynumer = [map keyEnumerator];
		BOOL keysAreStrings = NO;
		while( (subkey = [keynumer nextObject]) != nil )
		{
			if( ! [self keyIsNumber:subkey] )
			{
				keysAreStrings = YES;
        break;
			}
		}*/
    BOOL keysAreStrings = NO;
    for(NSString * subKey in [obj allKeys])
    {
      if( ! [self keyIsNumber:subKey] )
      {
        keysAreStrings = YES;
        break;
      }
    } 
		
		if( keysAreStrings )
			return XFPacketAttributeStringAttrMapType;
		else
			return XFPacketAttributeIntAttrMapType;
	}
	else if( [obj isKindOfClass:[XFPacketAttributeValue class]] )
	{
		XFPacketAttributeValue *pav = obj;
		return [pav typeID];
	}
	
	// if we fall through to here, return invalid type
	return XFPacketAttributeInvalidType;
}

+ (BOOL)keyIsNumber:(id)key
{
	//NSLog(@"keyIsNumber:%@",key);
	if( [key isKindOfClass:[NSString class]] )
	{
		if( [[key substringWithRange:NSMakeRange(0,2)] isEqualToString:@"0x"] )
		{
			return YES;
		}
	}
	else if( [key isKindOfClass:[NSNumber class]] )
	{
		// TODO: Check objCType ?
		return YES;
	}
	return NO;
}

// This is intended to be used locally only (by the above class methods).
// It assumes the arguments have been vetted and should be consistent
- (id)initWithValue:(id)aVal typeID:(int)tid arrayType:(int)atid
{
	if( (self = [super init]) )
  {
		_typeID = tid;
		_arrayElementType = atid;
		_value = [aVal retain];
		
		//NSLog(@"XFPacketAttributeValue -initWithValue:%@ typeID:%d arrayType:%d",aVal,tid,atid);
	}
	return self;
}

- (void)dealloc
{
	[_value release];
	[super dealloc];
}

- (int)typeID
{
	return _typeID;
}

- (id)value
{
	return _value;
}

- (int)arrayElementType
{
	return _arrayElementType;
}

- (NSString *)description
{
	if( [self typeID] == XFPacketAttributeStringType )
	{
		return [NSString stringWithFormat: @"[[ Packet Attribute, type = %d, arrType = %d, value = \"%@\" ]]",
			_typeID, _arrayElementType, _value];
	}
	else
	{
		return [NSString stringWithFormat: @"[[ Packet Attribute, type = %d, arrType = %d, value = %@ ]]",
			_typeID, _arrayElementType, _value];
	}
}

@end
