//
//  XFFriend.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//
//	Represents an Xfire data packet, can generate and scan data
//	for you.

#import "XFPacket.h"

#import "XfireKit.h"
#import "NSData_XfireAdditions.h"
#import "NSMutableData_XfireAdditions.h"
#include <arpa/inet.h>

#import "XFPacketAttributeValue.h"
#import "XFPacketDictionary.h"
#import "XFSession.h"

#define CHECK_LENGTH_EX(_need,_what)				\
if( (_idx + (_need)) > _len ) {		\
[self raiseException:[NSString stringWithFormat:@"Not enough bytes (%d,%d) to scan %@",(_len - (_idx)), (_need),(_what)]];	\
}
#define CHECK_LENGTH(_need)								\
unsigned int require = 0; if( isJumbo ) require = 1047552;\
else require = 65530;\
if( ([_data length] + (_need)) > require ) {			\
[self raiseException:@"Packet is too long"];	\
}

#define CHECK_LENGTH_32(_need)                                 \
if( ([_data length] + (_need)) > 4294967296 ) { \
[self raiseException:@"Packet is too long"]; \
}

// this defines whether the packets that are received should be logged, a very useful tool
// if something is broken in the current packet handling as xfire might change things in the
// protocol
#define JABWD 1

NSString * const XFPacketChecksumKey		= @"checksum";
NSString * const XFPacketChunksKey			= @"chunks";
NSString * const XFPacketEmailKey			= @"email";
NSString * const XFPacketFirstNameKey		= @"fname";
NSString * const XFPacketFlagsKey			= @"flags";
NSString * const XFPacketFriendsKey			= @"friends";
NSString * const XFPacketFriendSIDKey		= @"fnsid";
NSString * const XFPacketGameIDKey			= @"gameid";
NSString * const XFPacketGameIPKey			= @"gip";
NSString * const XFPacketGamePortKey		= @"gport";
NSString * const XFPacketIMKey				= @"im";
NSString * const XFPacketIMIndexKey			= @"imindex";

NSString * const XFPacketTypingKey			= @"typing";

NSString * const XFPacketLanguageKey		= @"lang";
NSString * const XFPacketLastNameKey		= @"lname";
NSString * const XFPacketMessageKey			= @"msg";
NSString * const XFPacketMessageTypeKey		= @"msgtype";
NSString * const XFPacketNameKey			= @"name";
NSString * const XFPacketNickNameKey		= @"nick";
NSString * const XFPacketPartnerKey			= @"partner";
NSString * const XFPacketPasswordKey		= @"password";
NSString * const XFPacketPeerMessageKey		= @"peermsg";

NSString * const XFPacketReasonKey			= @"reason";
NSString * const XFPacketSaltKey			= @"salt";
NSString * const XFPacketSessionIDKey		= @"sid";
NSString * const XFPacketSkinKey			= @"skin";
NSString * const XFPacketStatsKey			= @"stats";
NSString * const XFPacketStatusKey			= @"status";
NSString * const XFPacketThemeKey			= @"theme";
NSString * const XFPacketUserIDKey			= @"userid";
NSString * const XFPacketValueKey			= @"value";
NSString * const XFPacketVersionKey			= @"version";

NSString * const XFPacketCommandKey			= @"command";
NSString * const XFPacketFileKey			= @"file";
NSString * const XFPacketFileIDKey			= @"fileid";
NSString * const XFPacketPrefsKey			= @"prefs";
NSString * const XFPacketResultKey			= @"result";
NSString * const XFPacketStatusTextKey		= @"t";
NSString * const XFPacketTypeKey			= @"type";

NSString * const XFPacketConnectionKey		= @"conn";
NSString * const XFPacketNATKey				= @"nat";
NSString * const XFPacketSecKey				= @"sec";
NSString * const XFPacketClientIPKey		= @"clientip";
NSString * const XFPacketNATErrKey			= @"naterr";
NSString * const XFPacketUPNPInfoKey		= @"upnpinfo";

NSString * const XFPacketDownloadSetKey		= @"dlset";
NSString * const XFPacketPeerToPeerSetKey	= @"p2pset";
NSString * const XFPacketClientSetKey		= @"clntset";
NSString * const XFPacketMinRectKey			= @"minrect";
NSString * const XFPacketMaxRectKey			= @"maxrect";
NSString * const XFPacketCTryKey			= @"ctry";

NSString * const XFPacketNAT1Key			= @"n1";
NSString * const XFPacketNAT2Key			= @"n2";
NSString * const XFPacketNAT3Key			= @"n3";

NSString * const XFPacketPublicIPKey			= @"pip";

NSString * const XFPacketClientMessageKey	= @"climsg";

NSString * const XFPacketDownloadIDKey		= @"did";

NSString * const XFPacketIPKey				= @"ip";
NSString * const XFPacketPortKey			= @"port";
NSString * const XFPacketLocalIPKey			= @"localip";
NSString * const XFPacketLocalPortKey		= @"localport";

NSString * const XFPacketFilenameKey		= @"filename";
NSString * const XFPacketDescriptionKey		= @"desc";
NSString * const XFPacketSizeKey			= @"size";
NSString * const XFPacketMessageTimeKey		= @"mtime";
NSString * const XFPacketReplyKey			= @"reply";
NSString * const XFPacketOffsetKey			= @"offset";
NSString * const XFPacketChunkCountKey		= @"chunkcnt";
NSString * const XFPacketMessageIDKey		= @"msgid";
NSString * const XFPacketDataKey			= @"data";

/*
 checksum chunks clientip climsg clntset conn ctry
 did dlset
 fileid fileids flags friends
 gameid gcd gip gport
 ip
 lang localip localport
 max maxrect minrect msg
 name nat naterr nick n1 n2 n3
 origin
 partner password pip port p2pset
 salt sec skin sid status
 theme
 upnpinfo userid version
 withheld
 */





@implementation XFPacket

@synthesize attributes	= _attributes;
@synthesize data		= _data;
@synthesize isJumbo;
@synthesize packetID = _packetID;

// decode the raw data and build a new packet
+ (XFPacket *)decodedPacketByScanningBuffer:(NSData *)data
{
	if( data && ([data length] >= 5) )
	{
		@try
		{
			return [[[[XFPacket alloc] init] scan:data] autorelease];
		}
		@catch( NSException *e )
		{
			NSLog(@"*** Error while decoding packet data (%@)",e);
			return nil;
		}
	}
	
	return nil;
}

+ (XFPacket *)decodedJumboPacketByScanningBuffer:(NSData *)data
{
	if( data && ([data length] >= 5) )
	{
		@try {
			XFPacket *packet = [[XFPacket alloc] init];
			[packet setIsJumbo:YES];
			return [[packet scan:data] autorelease];
		}
		@catch (NSException *e) {
			NSLog(@"*** Error while decoding UDP packet data: %@",e);
			return nil;
		}
	}
	return nil;
}

- (id)initWithID:(XFPacketID)pktID attributeMap:(XFPacketDictionary *)attrs raw:(NSData *)raw isJumbo:(BOOL)jumbo
{
	if( (self = [super init]) )
	{
		isJumbo			= jumbo;
		_packetID		= pktID;
		_attributes		= [attrs retain];
		_data			= [raw copy];
	}
	return self;
}

- (void)dealloc
{
	[_attributes release];
	_attributes = nil;
	[_data release];
	_data = nil;
	[super dealloc];
}

- (NSUInteger)attributeCount
{
	return [_attributes count];
}

- (NSString *)description
{
	NSMutableString *str = [NSMutableString string];
	
	[str appendFormat:@"packet:  ID %d, %d attrs", _packetID, [self attributeCount]];
	
	[str appendFormat:@"\n%@\n", [_attributes description]];
	
	if( _data )
	{
		[str appendString:[_data enhancedDescription]];
	}
	
	return str;
}

- (id)attributeForKey:(id)key
{
	return [_attributes objectForKey:key];
}

// Compound accessor utility to get all values into an array, regardless of
// whether the packet has a single item or multiple items
- (NSArray *)attributeValuesForKey:(id)key
{
	XFPacketAttributeValue *mainAttrVal = [self attributeForKey:key];
	
	if( !mainAttrVal ) return nil;
	
	if( [mainAttrVal typeID] == XFPacketAttributeArrayType )
	{
		// multiple values
		NSArray        *mainAttrValArray = [mainAttrVal value];
		NSMutableArray *attrValues       = [[[NSMutableArray alloc] init] autorelease];
		
		NSUInteger i, cnt = [mainAttrValArray count];
		for( i = 0; i < cnt; i++ )
		{
			NSString *object = [[mainAttrValArray objectAtIndex:i] value];
			if( object != nil ){
				[attrValues addObject:object];
			} else {
				[attrValues addObject:@""];
			}
			
		}
		
		return attrValues;
	}
	else
	{
		// single value
		return [NSArray arrayWithObject:[mainAttrVal value]];
	}
}



#pragma mark - Packet scanner


- (BOOL)isAtEnd
{
	return (_idx == _len);
}

//------------------------------------------------------------------------------------------------
// Scanners of Primitive Values
// all the other scanning methods are built on these primitives
//------------------------------------------------------------------------------------------------

// scan a 1 byte integer
- (unsigned char)scanUInt8
{
	CHECK_LENGTH_EX(1,@"uint8");
	
	unsigned char v = _bytes[_idx];
	
	_idx += 1;
	return v;
}

// scan a 2 byte integer, assuming little endian order
- (unsigned short)scanUInt16
{
	CHECK_LENGTH_EX(2,@"uint16");
	
	unsigned short v = (
						((unsigned short)_bytes[_idx]) |
						(((unsigned short)_bytes[_idx+1]) << 8)
						);
	
	_idx += 2;
	return v;
}

// scan a 4 byte integer, assuming little endian order
- (unsigned int)scanUInt32
{
	CHECK_LENGTH_EX(4,@"uint32");
	
	unsigned int v = (
					  ((unsigned int)_bytes[_idx]) |
					  (((unsigned int)_bytes[_idx+1]) << 8) |
					  (((unsigned int)_bytes[_idx+2]) << 16) |
					  (((unsigned int)_bytes[_idx+3]) << 24)
					  );
	
	_idx += 4;
	return v;
}

// scan an 8 byte integer, assuming little endian order
- (unsigned long long)scanUInt64
{
	CHECK_LENGTH_EX(8,@"uint64");
	
	unsigned long long v = (
							((unsigned long long)_bytes[_idx]) |
							(((unsigned long long)_bytes[_idx+1]) << 8) |
							(((unsigned long long)_bytes[_idx+2]) << 16) |
							(((unsigned long long)_bytes[_idx+3]) << 24) |
							(((unsigned long long)_bytes[_idx+4]) << 32) |
							(((unsigned long long)_bytes[_idx+5]) << 40) |
							(((unsigned long long)_bytes[_idx+6]) << 48) |
							(((unsigned long long)_bytes[_idx+7]) << 56)
							);
	
	_idx += 8;
	return v;
}

// scan a 16 byte integer value, in order
// I figure this is probably a UUID, given how it's used
- (NSData *)scanUUID
{
	CHECK_LENGTH_EX(16,@"uuid");
	
	NSData *v = [NSData dataWithBytes:(&_bytes[_idx]) length:16];
	
	_idx += 16;
	return v;
}

// scan an attribute key string
// this is a UTF8 string with a leading 1 byte length
- (NSString *)scanAttrKeyString
{
	unsigned int len = [self scanUInt8];
	
	CHECK_LENGTH_EX(len,@"key string");
	
	NSString *s = [[[NSString alloc] initWithBytes:&_bytes[_idx]
											length:len
										  encoding:NSUTF8StringEncoding] autorelease];
	
	_idx += len;
	return s;
}

// scan a string
// this is a UTF8 string with a leading 2 byte length
- (NSString *)scanString
{
	unsigned int len = [self scanUInt16];
	NSString *s;
	
	CHECK_LENGTH_EX(len,@"string");
	
	if( len > 0 )
	{
		s = [[[NSString alloc] initWithBytes:&_bytes[_idx]
									  length:len
									encoding:NSUTF8StringEncoding] autorelease];
		
		
		_idx += len;
	}
	else
	{
		s = [NSString string];
	}
	
	return s;
}

// scan arbitrary length data
- (NSData *)scanDataOfLength:(unsigned int)len
{
	CHECK_LENGTH_EX(len,@"did");
	
	NSData *v = [NSData dataWithBytes:(&_bytes[_idx]) length:len];
	
	_idx += len;
	return v;
}

// Peek ahead one byte
- (unsigned char)peekUInt8
{
	CHECK_LENGTH_EX(1,@"uint8");
	return _bytes[_idx];
}

//------------------------------------------------------------------------------------------------
// Top level
//------------------------------------------------------------------------------------------------

- (XFPacket *)scan:(NSData *)data
{
    _idx    = 0;
    _len    = [data length];
    _bytes  = [data bytes];
    
	NSUInteger len;
	
	if( isJumbo )
		len = [self scanUInt32];
	else
		len = [self scanUInt16];
	
	
	if( len != _len )
	{
		[self raiseException:@"Length doesn't match"];
		return NO; // just to be sure
	}
	
	_packetID = (unsigned int)[self scanUInt16];
    
#if JABWD
	NSLog(@"packet id: %d",_packetID);
#endif
    
	// just to be sure so that we do not get any memory leaks..
    [_attributes release];
    _attributes = nil;
    [_data release];
    _data = nil;
    
	// scan the primary attribute map
	_attributes = [[self scanAttributeMapInDomain:[self keyDomainForPacketType:_packetID]] retain];
    
    _data        = [data copy];
	return self;
}

- (XFAttributeKeyDomain)keyDomainForPacketType:(unsigned short)type{
	if (
		type == 1  ||					// 1
		type == 2  ||					// 2
		type == 3  ||					// 3
		type == 5  ||			// 5
		type == 6  ||		// 6
		type == 7  ||		// 7
		type == 8  ||	// 8
		type == 9  ||			// 9
		type == 10 ||					// 10
		type == 12 ||				// 12
		type == 13 ||				// 13
		type == 14 ||			// 14
		type == 16 ||					// 16
		type == 17 ||				// 17
		
		// p2p
		type == XFClientP2PFileTransferRequestPacketID		||
		type == XFClientP2PFileTransferRequestReplyPacketID	||
		type == XFClientP2PFileTransferInfoPacketID			||
		type == XFClientP2PFileTransferEventPacketID			||
		type == XFClientP2PFileTransferDataRequestPacketID	||
		type == XFClientP2PFileTransferDataPacketID			||
		type == XFClientP2PFileTransferCompletePacketID		||
		type == XFClientP2PFileTransferChunkInfoPacketID		||
		
		type == 128 ||					// 128
		type == 129 ||					// 129
		type == 130 ||					// 130
		type == 131 ||					// 131
		/*  type == 132 ||	 */					// 132
		type == 133 ||					// 133
		type == 134 ||					// 134
		type == 135 ||					// 135
		type == 136 ||				// 136
		type == 137 ||				// 137
		type == 138 ||					// 138
		type == 139 ||					// 139
		type == 143 ||					// 143
		type == 144 ||				// 144
		type == 145 ||		// 145
		type == 147 ||			// 147
		type == 148 ||			// 148
		type == 154 ||					// 154
		type == 156 ||				// 156
		
		type == 400						// 400
		
		) {
		return XFAttributeKeyStringDomain;
	}
	
	return XFAttributeKeyIntegerDomain;
}

- (XFPacketDictionary *)scanAttributeMapInDomain:(XFAttributeKeyDomain)domain
{
	unsigned int attrCnt,i;
	XFPacketDictionary *attributes = [XFPacketDictionary map];
	
	NSString *attrKey;
	id       attrValue;
	
	attrCnt = (unsigned int)[self scanUInt8];
	
	for( i = 0; i < attrCnt; i++ )
	{
		[self scanAttribute:&attrKey keyDomain:domain value:&attrValue ];
		[attributes setObject:attrValue forKey:attrKey];
	}
	
#if JABWD
	NSLog(@"%@",attributes);
#endif
	
	return attributes;
}

- (void)scanAttribute:(NSString **)keyOut keyDomain:(XFAttributeKeyDomain)domain value:(id *)valueOut
{
	NSString *key = nil;
	
	// first scan the attribute key, converting to string as necessary
	
	if( domain == XFAttributeKeyIntegerDomain )
	{
		unsigned int keyInt = (unsigned int)[self scanUInt8];
		key = [NSString stringWithFormat:@"0x%02x",keyInt];
	}
	else if( domain == XFAttributeKeyStringDomain )
	{
		key = [self scanAttrKeyString];
	}
	else
	{
		[self raiseException:@"Internal scan error - unrecognized key domain"];
	}
	
	// second scan the attribute value
	
	id value = [self scanAttributeValue];
	
	// lastly return the results
	
	if( keyOut ) *keyOut = key;
	if( valueOut ) *valueOut = value;
}


//------------------------------------------------------------------------------------------------
// Scanners of the Attribute Type Stream
//------------------------------------------------------------------------------------------------


- (id)scanAttributeValue
{
	unsigned char type = [self scanUInt8];
	switch( type )
	{
		case 0x01: return [XFPacketAttributeValue attributeValueWithString:[self scanString]]; break;
		case 0x02: return [XFPacketAttributeValue attributeValueWithInt:[self scanUInt32]]; break;
		case 0x03: return [XFPacketAttributeValue attributeValueWithUUID:[self scanUUID]]; break;
		case 0x04:
		{
			// need to peek before scanning the array
			int emptyElementType = (int)[self peekUInt8];
			return [XFPacketAttributeValue attributeValueWithArray:[self scanArray] emptyElementType:emptyElementType];
		}
			break;
		case 0x05: return [XFPacketAttributeValue attributeValueWithAttributeMap:[self scanAttributeMapInDomain:XFAttributeKeyStringDomain]]; break;
		case 0x06: return [XFPacketAttributeValue attributeValueWithDid:[self scanDataOfLength:21]]; break;
		case 0x07: return [XFPacketAttributeValue attributeValueWithInt64:[self scanUInt64]]; break;
		case 0x08: return [XFPacketAttributeValue attributeValueWithByte:[self scanUInt8]]; break;
		case 0x09: return [XFPacketAttributeValue attributeValueWithAttributeMap:[self scanAttributeMapInDomain:XFAttributeKeyIntegerDomain]]; break;
			
		default:
			[self raiseException:[NSString stringWithFormat:@"Unexpected type ID (%02x)", type]];
			break;
	}
	return nil;
}

// Very similar to -scanAttributeValue, but scans a sequence of values instead of just one
- (NSArray *)scanArray
{
	NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
	
	// this is a work around to make the file transfer packets use less CPU power..
	if( _packetID == XFClientP2PFileTransferDataPacketID )
	{
		unsigned char elementType = [self scanUInt8];
		unsigned int i, cnt = [self scanUInt16];
		NSMutableData *finalData = [[NSMutableData alloc] init];
		switch (elementType)
		{
			case 0x01:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithString:[self scanString]]];
				break;
				
			case 0x02:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithInt:[self scanUInt32]]];
				break;
				
			case 0x03:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithUUID:[self scanUUID]]];
				break;
				
			case 0x04:
				for( i = 0; i < cnt; i++ )
				{
					int emptyElementType = (int)[self peekUInt8];
					[arr addObject:[XFPacketAttributeValue attributeValueWithArray:[self scanArray] emptyElementType:emptyElementType]];
				}
				break;
				
			case 0x05:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithAttributeMap:[self scanAttributeMapInDomain:XFAttributeKeyStringDomain]]];
				break;
				
			case 0x06:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithDid:[self scanDataOfLength:21]]];
				break;
				
			case 0x07:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithInt64:[self scanUInt64]]];
				break;
				
			case 0x08:
				//for( i = 0; i < cnt; i++ )
				//	[arr addObject:[XFPacketAttributeValue attributeValueWithByte:[self scanUInt8]]];
				for( i = 0; i < cnt; i ++ )
					[finalData appendByte:[self scanUInt8]];
				break;
				
			case 0x09:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithAttributeMap:[self scanAttributeMapInDomain:XFAttributeKeyIntegerDomain]]];
				break;
				
			default:
				[self raiseException:[NSString stringWithFormat:@"Unexpected type while scanning array (%02x)", elementType]];
				break;
		}
		[arr addObject:[XFPacketAttributeValue attributeValueWithData:finalData]];
		[finalData release];
	}
	else
	{
		// first byte of array is type of each element, assume it can be anything
		// second byte is the # of entries
		unsigned char elementType   = [self scanUInt8];
		unsigned int i, cnt         = [self scanUInt16];
		
		switch( elementType )
		{
			case 0x01:
				for( i = 0; i < cnt; i++ )
				{
					XFPacketAttributeValue *value = [[XFPacketAttributeValue alloc]
													 initWithValue:[self scanString]
													 typeID:XFPacketAttributeStringType
													 arrayType:XFPacketAttributeInvalidType
													 ];
					[arr addObject:value];
					[value release];
				}
				break;
				
			case 0x02:
				for( i = 0; i < cnt; i++ )
				{
					NSNumber *nr = [[NSNumber alloc] initWithUnsignedInt:[self scanUInt32]];
					XFPacketAttributeValue *value = [[XFPacketAttributeValue alloc]
													 initWithValue:nr
													 typeID:XFPacketAttributeUInt32Type
													 arrayType:XFPacketAttributeInvalidType
													 ];
					[arr addObject:value];
					[nr release];
					[value release];
				}
				break;
				
			case 0x03:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithUUID:[self scanUUID]]];
				break;
				
			case 0x04:
				for( i = 0; i < cnt; i++ )
				{
					int emptyElementType = (int)[self peekUInt8];
					[arr addObject:[XFPacketAttributeValue attributeValueWithArray:[self scanArray] emptyElementType:emptyElementType]];
				}
				break;
				
			case 0x05:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithAttributeMap:[self scanAttributeMapInDomain:XFAttributeKeyStringDomain]]];
				break;
				
			case 0x06:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithDid:[self scanDataOfLength:21]]];
				break;
				
			case 0x07:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithInt64:[self scanUInt64]]];
				break;
				
			case 0x08:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithByte:[self scanUInt8]]];
				break;
				
			case 0x09:
				for( i = 0; i < cnt; i++ )
					[arr addObject:[XFPacketAttributeValue attributeValueWithAttributeMap:[self scanAttributeMapInDomain:XFAttributeKeyIntegerDomain]]];
				break;
				
			default:
				[self raiseException:[NSString stringWithFormat:@"Unexpected type while scanning array (%02x)", elementType]];
				break;
		}
	}
	
	return arr;
}

- (void)raiseException:(NSString *)desc
{
	@throw [NSException exceptionWithName:@"XFPacketScannerException" reason:desc userInfo:nil];
}






#pragma mark - Packet generator


// generate a 1 byte integer
- (void)generateUInt8:(unsigned char)value
{
	CHECK_LENGTH(1);
	
	[_data appendByte:value];
}

// generate a 2 byte integer, assuming little endian order
- (void)generateUInt16:(unsigned short)value
{
	CHECK_LENGTH(2);
	
	unsigned char bfr[2];
	
	bfr[0] = (value & 0xFF);
	bfr[1] = ((value >> 8) & 0xFF);
	
	[_data appendBytes:bfr length:2];
}

// generate a 4 byte integer, assuming little endian order
- (void)generateUInt32:(unsigned int)value
{
	CHECK_LENGTH(4);
	
	unsigned char bfr[4];
	
	bfr[0] = (value & 0xFF);
	bfr[1] = ((value >> 8) & 0xFF);
	bfr[2] = ((value >> 16) & 0xFF);
	bfr[3] = ((value >> 24) & 0xFF);
	
	[_data appendBytes:bfr length:4];
}

- (void)generateUInt64:(unsigned long long)value{
	CHECK_LENGTH(8);
	
	unsigned char bfr[8];
	
	bfr[0] = (value & 0xFF);
	bfr[1] = ((value >> 8) & 0xFF);
	bfr[2] = ((value >> 16) & 0xFF);
	bfr[3] = ((value >> 24) & 0xFF);
	bfr[4] = ((value >> 32) & 0xFF);
	bfr[5] = ((value >> 40) & 0xFF);
	bfr[6] = ((value >> 48) & 0xFF);
	bfr[7] = ((value >> 56) & 0xFF);
	
	[_data appendBytes:bfr length:8];
}

// generate a 16 byte integer value, in order
// I figure this is probably a UUID, given how it's used
- (void)generateUUID:(NSData *)uuid
{
	if( [uuid length] != 16 )
		[self raiseException:@"Expected 16 bytes for UUID"];
	
	CHECK_LENGTH(16);
	
	[_data appendData:uuid];
}

// scan an attribute key string
// this is a UTF8 string with a leading 1 byte length
- (void)generateAttrKeyString:(NSString *)str
{
	NSData *utf8str = [str dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger strLen = [utf8str length];
	
	CHECK_LENGTH( strLen + 1 );
	
	if( strLen >= 256 )
		[self raiseException:@"Attribute key string is too long for 1 byte length"];
	
	[self generateUInt8:(unsigned char)strLen];
	
	[_data appendData:utf8str];
}

// generate a string
// this is a UTF8 string with a leading 2 byte length
- (void)generateString:(NSString *)str
{
	NSData *utf8str = [str dataUsingEncoding:NSUTF8StringEncoding];
	NSUInteger strLen = [utf8str length];
	
	CHECK_LENGTH( strLen + 2 );
	
	if( strLen >= 65536 )
		[self raiseException:@"String is too long for 2 byte length"];
	
	[self generateUInt16:(unsigned short)strLen];
	
	[_data appendData:utf8str];
}

// 21 byte value
- (void)generateDID:(NSData *)data
{
	if( [data length] != 21 )
		[self raiseException:@"Expected 21 bytes for DID"];
	
	CHECK_LENGTH(21);
	
	[_data appendData:data];
}

//------------------------------------------------------------------------------------------------
// Generators of the Attribute Type Stream
//------------------------------------------------------------------------------------------------

// TODO: sanity check the packet content
// TODO: generate attributes in specific order
- (void)generatePacket
{
	[_data release];
	_data = [[NSMutableData alloc] initWithCapacity:65536];
	if( [_attributes count] > 255 )
		[self raiseException:@"Too many attributes"];
	
	[self generateAttributeMap:_attributes];
	
	// then prepend the header and return
	unsigned int finalLen = (unsigned int)[_data length] + 4;
	
	NSMutableData *tmp = _data;
	
	_data = [[NSMutableData alloc] init];
	if( isJumbo )
		[self generateUInt32:finalLen];
	else
		[self generateUInt16:finalLen];
	[self generateUInt16:_packetID];
	
	[_data appendData:tmp];
	
	
	[tmp release];
}

- (void)generateAttributeMap:(XFPacketDictionary *)attrs
{
	// first the count byte
	[self generateUInt8:[attrs count]];
	
	for( NSString *theKey in [attrs allKeys])
		[self generateAttribute:theKey value:[attrs objectForKey:theKey]];
}

- (void)generateAttribute:(id)key value:(XFPacketAttributeValue *)val
{
	// generate the key
	// check if the key should be a number or a string
	if( [key isKindOfClass:[NSString class]] )
	{
		if( [[((NSString*)key) substringWithRange:NSMakeRange(0,2)] isEqualToString:@"0x"] )
		{
			int kv = [self intForKeyString:key];
			[self generateUInt8:(unsigned char)kv];
		}
		else
		{
			[self generateAttrKeyString:key];
		}
	}
	else if( [key isKindOfClass:[NSNumber class]] )
	{
		[self generateUInt8:[((NSNumber*)key) unsignedCharValue]];
	}
	else
	{
		[self raiseException:@"Invalid packet attribute key"];
	}
	int typeID = [val typeID];
	// now generate the value
	switch(typeID)
	{
		case XFPacketAttributeStringType:
			[self generateUInt8:0x01];
			[self generateString:((NSString*)[val value])];
			break;
			
		case XFPacketAttributeUInt32Type:
			[self generateUInt8:0x02];
			[self generateUInt32:[((NSNumber*)[val value]) unsignedIntValue]];
			break;
			
		case XFPacketAttributeUUIDType:
			[self generateUInt8:0x03];
			[self generateUUID:((NSData *)[val value])];
			break;
			
		case XFPacketAttributeArrayType:
			[self generateUInt8:0x04];
			[self generateArray:val];
			break;
			
		case XFPacketAttributeStringAttrMapType:
			[self generateUInt8:0x05];
			[self generateAttributeMap:((XFPacketDictionary *)[val value])];
			break;
			
		case XFPacketAttributeDIDType:
			[self generateUInt8:0x06];
			[self generateDID:((NSData *)[val value])];
			break;
			
		case XFPacketAttributeUInt64Type :
			[self generateUInt8:0x07];
			[self generateUInt64:[((NSNumber*)[val value]) unsignedIntValue]];
			break;
			
		case XFPacketAttributeUInt8Type :
			[self generateUInt8:0x08];
			[self generateUInt8:[(NSNumber *)[val value] unsignedCharValue]];
			break;
			
			
		case XFPacketAttributeIntAttrMapType:
			[self generateUInt8:0x09];
			[self generateAttributeMap:((XFPacketDictionary *)[val value])];
			break;
			
		default:
			[self raiseException:[NSString stringWithFormat:@"Unrecognized attribute value type (%02x)", (unsigned char)typeID]];
			break;
	}
}

- (void)generateArray:(XFPacketAttributeValue *)arrayAttr
{
	NSArray *arr = [arrayAttr value];
	XFPacketAttributeValue *pav;
	
	// simple case = empty array
	NSUInteger i, cnt = [arr count];
	if( cnt == 0 )
	{
		[self generateUInt8:[arrayAttr arrayElementType]];
		[self generateUInt16:0]; // no items in the array
		
		return; // no more to do here
	}
	else if( cnt > 65535 )
	{
		[self raiseException:@"Too many elements in array"];
	}
	
	// generate each element of the array
	switch( [arrayAttr arrayElementType] )
	{
		case XFPacketAttributeStringType:
			[self generateUInt8:0x01];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateString:[pav value]];
			}
			break;
			
		case XFPacketAttributeUInt32Type:
			[self generateUInt8:0x02];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateUInt32:[((NSNumber*)[pav value]) unsignedIntValue]];
			}
			break;
			
		case XFPacketAttributeUUIDType:
			[self generateUInt8:0x03];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateUUID:[pav value]];
			}
			break;
			
		case XFPacketAttributeDIDType:
			[self generateUInt8:0x06];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateDID:[pav value]];
			}
			break;
			
		case XFPacketAttributeArrayType:
			[self generateUInt8:0x04];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateArray:pav];
			}
			break;
			
		case XFPacketAttributeStringAttrMapType:
			[self generateUInt8:0x05];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateAttributeMap:[pav value]];
			}
			break;
			
		case XFPacketAttributeIntAttrMapType:
			[self generateUInt8:0x09];
			[self generateUInt16:cnt];
			
			for( i = 0; i < cnt; i++ )
			{
				pav = [arr objectAtIndex:i];
				[self generateAttributeMap:[pav value]];
			}
			break;
			
		default:
			[self raiseException:[NSString stringWithFormat:@"Unrecognized element type while generating array (%d)",
								  [arrayAttr arrayElementType]]];
			break;
	}
}

- (BOOL)keyStringIsNumber:(NSString *)key
{
	if( [[key substringWithRange:NSMakeRange(0,2)] isEqualToString:@"0x"] )
	{
		return YES;
	}
	return NO;
}

// scan the hex string format "0x##" and return the integer
- (int)intForKeyString:(NSString *)key
{
	NSString *str = [key substringWithRange:NSMakeRange(2,2)];
	int v;
	const char *utfs = [str UTF8String];
	if( sscanf(utfs,"%x",&v) != 1 )
		[self raiseException:@"Invalid attribute key"];
	return v;
}

+ (id)packet
{
	return [[[XFPacket alloc] init] autorelease];
}

// username/password packet (ID 1)
+ (id)loginPacketWithUsername:(NSString *)name password:(NSString *)pass flags:(unsigned int)flg
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	if( [pass length] != 40 )
	{
		@throw [NSException exceptionWithName:@"XFPacket" reason:@"Attempt to create packet with invalid password hash" userInfo:nil];
	}
	
	[pkt setPacketID: 0x01];
	XFPacketAttributeValue *value = [[XFPacketAttributeValue alloc]
									 initWithValue:name
									 typeID:XFPacketAttributeStringType
									 arrayType:XFPacketAttributeInvalidType
									 ];
	[pkt setAttribute:value forKey:XFPacketNameKey];
	[value release];
	value = [[XFPacketAttributeValue alloc]
			 initWithValue:pass
			 typeID:XFPacketAttributeStringType
			 arrayType:XFPacketAttributeInvalidType
			 ];
	[pkt setAttribute:value forKey:XFPacketPasswordKey];
	[value release];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:flg]
			   forKey:XFPacketFlagsKey];
	
	[pkt generate];
	return pkt;
}

//Typing notification packet
+ (id)chatTypingNotificationPacketWithSID:(NSData *)sid imIndex:(unsigned int)imidx typing:(unsigned int)typing
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *peermsg = [XFPacketDictionary map];
	
	[pkt setPacketID:0x02];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithUUID:sid]
			   forKey:XFPacketSessionIDKey];
	
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:3]
				forKey:XFPacketMessageTypeKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:imidx]
				forKey:XFPacketIMIndexKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:YES]
				forKey:XFPacketTypingKey];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:peermsg]
			   forKey:XFPacketPeerMessageKey];
	
	[pkt generate];
	return pkt;
}

// chat messages (ID 2)

// acknowledge receipt of a chat message
+ (id)chatAcknowledgementPacketWithSID:(NSData *)sid imIndex:(unsigned int)imidx
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *peermsg = [XFPacketDictionary map];
	
	[pkt setPacketID: 0x02];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithUUID:sid]
			   forKey:XFPacketSessionIDKey];
	
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:1]
				forKey:XFPacketMessageTypeKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:imidx]
				forKey:XFPacketIMIndexKey];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:peermsg]
			   forKey:XFPacketPeerMessageKey];
	
	[pkt generate];
	return pkt;
}

+ (id)chatRequestPeerToPeerSessionPacketWithFriendSessionID:(NSData *)sessionID
                                            publicIPAddress:(unsigned int)publicIPAddress
                                                 publicPort:(unsigned short)publicPort
                                             localIPAddress:(unsigned int)localIPAddress
                                                  localPort:(unsigned short)localPort
                                                    natType:(unsigned int)natType
                                                       salt:(NSString *)salt {
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *peermsg = [XFPacketDictionary map];
	[pkt setPacketID:XFClientChatPacketID];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithUUID:sessionID] forKey:XFPacketSessionIDKey];
	
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0x02] forKey:XFPacketMessageTypeKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:publicIPAddress] forKey:XFPacketIPKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:publicPort     ] forKey:XFPacketPortKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:localIPAddress ] forKey:XFPacketLocalIPKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:localPort      ] forKey:XFPacketLocalPortKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:natType        ] forKey:XFPacketStatusKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithString:salt        ] forKey:XFPacketSaltKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:peermsg] forKey:XFPacketPeerMessageKey];
	[pkt generate];
	
	return pkt;
}

+ (id)chatPeerToPeerInfoResponseWithSalt:(NSString *)salt sid:(NSData *)sidd
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *peermsg = [XFPacketDictionary map];
	
	[pkt setPacketID:0x02];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithUUID:sidd] forKey:XFPacketSessionIDKey];
	
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:2]
				forKey:XFPacketMessageTypeKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0]
				forKey:@"ip"];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0]
				forKey:@"port"];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0]
				forKey:@"localip"];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0]
				forKey:@"localport"];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0]
				forKey:@"status"];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithString:salt]
				forKey:XFPacketSaltKey];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:peermsg]
			   forKey:XFPacketPeerMessageKey];
	
	[pkt generate];
	
	return pkt;
}

// send an instant message
+ (id)chatInstantMessagePacketWithSID:(NSData *)sid imIndex:(unsigned int)imidx message:(NSString *)msg
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *peermsg = [XFPacketDictionary map];
	
	[pkt setPacketID: 0x02];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithUUID:sid]
			   forKey:XFPacketSessionIDKey];
	
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:0]
				forKey:XFPacketMessageTypeKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithInt:imidx]
				forKey:XFPacketIMIndexKey];
	[peermsg setObject:[XFPacketAttributeValue attributeValueWithString:msg]
				forKey:XFPacketIMKey];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:peermsg]
			   forKey:XFPacketPeerMessageKey];
	
	[pkt generate];
	return pkt;
}

// client version packet (ID 3)
+ (id)clientVersionPacket:(unsigned int)vers
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 0x03];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:vers]
			   forKey:XFPacketVersionKey];
	
	[pkt generate];
	return pkt;
}

// game status change packet (ID 4)
+ (id)gameStatusChangePacketWithGameID:(unsigned)gid gameIP:(unsigned)gip gamePort:(unsigned)port
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setPacketID: 0x04];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:gid]
			   forKey:XFPacketGameIDKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:gip]
			   forKey:XFPacketGameIPKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:port]
			   forKey:XFPacketGamePortKey];
	
	[pkt generate];
	return pkt;
}

// Friend of Friend info request (ID 5)
+ (id)friendOfFriendRequestPacketWithSIDs:(NSArray *)sessionIDs
{
	NSMutableArray *sidArray = [NSMutableArray array];
	NSData         *sid;
	NSUInteger i, cnt = [sessionIDs count];
	if( cnt == 0 )
		@throw [NSException exceptionWithName:@"XFPacket" reason:@"Attempt to create friend of friend request without any session IDs" userInfo:nil];
	
	for( i = 0; i < cnt; i++ )
	{
		sid = [sessionIDs objectAtIndex:i];
		if( ! [sid isKindOfClass:[NSData class]] )
			@throw [NSException exceptionWithName:@"XFPacket" reason:@"Attempt to create friend of friend request with invalid session ID" userInfo:nil];
		if( [sid length] != 16 )
			@throw [NSException exceptionWithName:@"XFPacket" reason:@"Attempt to create friend of friend request with invalid session ID" userInfo:nil];
		
		[sidArray addObject:[XFPacketAttributeValue attributeValueWithUUID:sid]];
	}
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setPacketID: 5];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithArray:sidArray emptyElementType:3]
			   forKey:XFPacketSessionIDKey];
	
	[pkt generate];
	return pkt;
}

// Add-friend request (ID 6)
+ (id)addFriendRequestPacketWithUserName:(NSString *)un message:(NSString *)msg
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 6];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:un]
			   forKey:XFPacketNameKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:msg]
			   forKey:XFPacketMessageKey];
	
	[pkt generate];
	return pkt;
}

// Accept incoming add-friend request (ID 7)
+ (id)acceptFriendRequestPacketWithUserName:(NSString *)un
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 7];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:un]
			   forKey:XFPacketNameKey];
	
	[pkt generate];
	return pkt;
}

// Decline incoming add-friend request (ID 8)
+ (id)declineFriendRequestPacketWithUserName:(NSString *)un
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 8];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:un]
			   forKey:XFPacketNameKey];
	
	[pkt generate];
	return pkt;
}

// Add-friend request (ID 9)
+ (id)removeFriendRequestWithUserID:(unsigned int)uid
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 9];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:uid]
			   forKey:XFPacketUserIDKey];
	
	[pkt generate];
	return pkt;
}

// Change user options packet (ID 10)
// Pass options with keys equal to the packet attribute map keys and values as NSNumber.bool
+ (id)changeOptionsPacket
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *map = [XFPacketDictionary map];
	
	[pkt setPacketID: 10];
    
    NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"showOthersGameStatus"]] stringValue]] 
            forKey:@"0x01"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"xfireShowGameServerData"]] stringValue]] 
            forKey:@"0x02"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"xfireStatusOnProfile"]] stringValue]] 
            forKey:@"0x03"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"enableTimeStamps"]] stringValue]] 
            forKey:@"0x06"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"showFriendsOfFriendsGroup"]] stringValue]] 
            forKey:@"0x08"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"showOfflineFriendsGroup"]] stringValue]] 
            forKey:@"0x09"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:(![std boolForKey:@"forceUsername"])] stringValue]] 
            forKey:@"0x0a"];
    
    [map setObject:[XFPacketAttributeValue 
                    attributeValueWithString:[[NSNumber numberWithBool:[std boolForKey:@"showOthersWhenTyping"]] stringValue]] 
            forKey:@"0x0c"];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:map]
			   forKey:XFPacketPrefsKey];
	
	[pkt generate];
	return pkt;
}

// user search packet (ID 12)
+ (id)userSearchPacketWithName:(NSString *)name fname:(NSString *)fn lname:(NSString *)ln email:(NSString *)em
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 12];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:name]
			   forKey:XFPacketNameKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:(fn?fn:@"")]
			   forKey:XFPacketFirstNameKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:(ln?ln:@"")]
			   forKey:XFPacketLastNameKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:(em?em:@"")]
			   forKey:XFPacketEmailKey];
	
	[pkt generate];
	return pkt;
}

// connection keepalive packet (ID 13)
+ (id)keepAlivePacketWithValue:(unsigned)val stats:(NSArray *)stats
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 13];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:val]
			   forKey:XFPacketValueKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithArray:stats emptyElementType:2]
			   forKey:XFPacketStatsKey];
	
	[pkt generate];
	return pkt;
}

// Change nickname (ID 14)
+ (id)changeNicknamePacketWithName:(NSString *)nick
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 14];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:(nick?nick:@"")]
			   forKey:XFPacketNickNameKey];
	
	[pkt generate];
	return pkt;
}

/*
 * This will request the xfire server for some more information about the XFFriend, like
 * Screenshots, videos and things like that.
 */
+ (id)friendInfoPacket:(unsigned int)userID
{
	if( userID == 0 ) return nil;
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setPacketID:37];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:userID] forKey:@"0x01"];
	
	[pkt generate];
	return pkt;
}

// client information packet (ID 16)
+ (id)clientInfoPacketWithLanguage:(NSString *)lng skin:(NSString *)skn theme:(NSString *)thm partner:(NSString *)prt
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 16];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:lng]
			   forKey:XFPacketLanguageKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:skn]
			   forKey:XFPacketSkinKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:thm]
			   forKey:XFPacketThemeKey];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:prt]
			   forKey:XFPacketPartnerKey];
	
	[pkt generate];
	return pkt;
}

// client network info packet (ID 17)
+ (id)networkInfoPacketWithConn:(unsigned)conn nat:(BOOL)isNat sec:(unsigned)sec ip:(unsigned)ip naterr:(BOOL)nErr uPnPInfo:(NSString *)info
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 17];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:conn]    forKey:@"conn"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:isNat]   forKey:@"nat"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:sec]     forKey:@"sec"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:ip]      forKey:@"clientip"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:nErr]    forKey:@"naterr"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:info] forKey:@"upnpinfo"];
	
	[pkt generate];
	return pkt;
}

// add custom friend group packet (ID 26)
+ (id)addCustomFriendGroupPacketWithName:(NSString *)groupName
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 26];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:groupName]
			   forKey:[NSNumber numberWithInt:0x1a]];
	
	[pkt generate];
	return pkt;
}

// remove custom friend group packet (ID 27)
+ (id)removeCustomFriendGroupPacket:(unsigned)groupID
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 27];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:groupID]
			   forKey:[NSNumber numberWithInt:0x19]];
	
	[pkt generate];
	return pkt;
}

// rename custom friend group packet (ID 28)
+ (id)renameCustomFriendGroupPacket:(unsigned)groupID newName:(NSString *)groupName
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 28];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:groupID]
			   forKey:[NSNumber numberWithInt:0x19]];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:groupName]
			   forKey:[NSNumber numberWithInt:0x1a]];
	
	[pkt generate];
	return pkt;
}

// add friend to custom friend group (ID 29)
+ (id)addFriendPacket:(unsigned)friendID toCustomGroup:(unsigned)groupID
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 29];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:friendID]
			   forKey:[NSNumber numberWithInt:0x01]];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:groupID]
			   forKey:[NSNumber numberWithInt:0x19]];
	
	[pkt generate];
	return pkt;
}

// remove friend from custom friend group (ID 30)
+ (id)removeFriendPacket:(unsigned)friendID fromCustomGroup:(unsigned)groupID
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 30];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:friendID]
			   forKey:[NSNumber numberWithInt:0x01]];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:groupID]
			   forKey:[NSNumber numberWithInt:0x19]];
	
	[pkt generate];
	return pkt;
}

// status text change packet (ID 32)
+ (id)statusTextChangePacket:(NSString *)newText
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 32];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:(newText?newText:@"")]
			   forKey:[NSNumber numberWithInt:0x2e]];
	
	[pkt generate];
	return pkt;
}

+ (id)addFavoriteServerPacket:(unsigned int)gameID serverIP:(NSString *)ip serverPort:(NSString *)gamePort{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setPacketID:19];
	unsigned int serverIP = 0;
	inet_pton(AF_INET, [ip UTF8String], &serverIP);
	serverIP = NSSwapHostIntToBig(serverIP);
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:gameID] forKey:@"gameid"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:serverIP] forKey:@"gip"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:[gamePort intValue]] forKey:@"gport"];
	[pkt generate];
	return pkt;
}

+ (id)removeFavoriteServerPacket:(unsigned int)gameID serverIP:(NSString *)ip serverPort:(NSString *)gamePort{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setPacketID:20];
	unsigned int serverIP = 0;
	inet_pton(AF_INET, [ip UTF8String], &serverIP);
	serverIP = NSSwapHostIntToBig(serverIP);
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:gameID] forKey:@"gameid"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:serverIP] forKey:@"gip"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:[gamePort intValue]] forKey:@"gport"];
	[pkt generate];
	return pkt;
}

#pragma mark Chat room support

+ (id)createNewChatRoom:(NSString *)roomName withPassword:(NSString *)password{
	if( [roomName length] < 1 )
		return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 0x0019
	
	unsigned int *tmp = malloc(21);
	memset(tmp, 0, 21);
	NSData *data = [[NSData alloc] initWithBytes:tmp length:21];
	free(tmp);
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CF4] forKey:@"climsg"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:data] forKey:@"0x04"]; [data release];
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:1] forKey:@"0x0b"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:1] forKey:@"0xaa"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:roomName] forKey:@"0x05"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:password] forKey:@"0x5f"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithByte:0x0] forKey:@"0xa7"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	
	
	[pkt generate];
	return pkt;
}

+ (id)inviteFriendToRoomPacket:(NSData *)roomSid withUser:(unsigned int)userID{
	if( [roomSid length] != 21 ) return nil;
	if( userID == 0 )            return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	NSArray *arr = [NSArray arrayWithObjects:
					[XFPacketAttributeValue attributeValueWithInt:userID],
					nil];
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CFC] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:roomSid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithArray:arr] forKey:@"0x18"]; // array with userID
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)joinChatRoomPacket:(NSData *)sid withName:(NSString *)roomName andPassword:(NSString *)password{
	if( [roomName length] < 1 ) return nil;
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 0x0019
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CF4] forKey:@"climsg"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid] forKey:@"0x04"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:1] forKey:@"0x0b"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:1] forKey:@"0xaa"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:roomName] forKey:@"0x05"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:password] forKey:@"0x5f"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithByte:0x0] forKey:@"0xa7"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)leaveChatRoomPacket:(NSData*)sid{
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 0x0019
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CF5] forKey:@"climsg"];
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid] forKey:@"0x04"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)denyRoomInvitationPacket:(NSData *)roomSid{
	if( [roomSid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CFF] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:roomSid]  forKey:@"0x04"]; // group chat SID
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)sendChatRoomMessagePacket:(NSData *)sid withMessage:(NSString *)message{
	if( [message length] < 1 ) return nil;
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CF6] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:message] forKey:@"0x2e"]; // array with userID
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)changeRoomPasswordPacket:(NSString *)newPassword forSID:(NSData *)sid
{
	if( ! newPassword )      return nil;
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19];
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4D15] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:newPassword] forKey:@"0x5F"]; // the name
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)changeSaveChatRoomPacket:(BOOL)save forSID:(NSData *)sid
{
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19];
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CFD] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithByte:(unsigned char)save] forKey:@"0x2a"]; // the name
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)changeRoomAccessPacket:(BOOL)access forSID:(NSData *)sid
{
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19];
	int flag = 0;
	if( access ) flag = 1;
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4D16] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:flag] forKey:@"0x17"]; // the name
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)changeRoomNamePacket:(NSString *)newName forSID:(NSData *)sid{
	if( [newName length] < 1 )  return nil;
	if( [sid length] != 21 )    return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CF8] forKey:@"climsg"];
	
	/* [msg2 setObject:[XFPacketAttributeValue attributeValueWithInt:0x00000000] forKey:@"0x0e"];
	 [msg2 setObject:[XFPacketAttributeValue attributeValueWithString:message] forKey:@"0x0f"];*/
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:newName] forKey:@"0x05"]; // the name
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)changeMotdPacket:(NSString *)newMotd forSID:(NSData *)sid{
	if( [newMotd length] == 0 ) return nil;
	if( [sid length] != 21    ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4D0C] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithString:newMotd] forKey:@"0x2e"]; // the new MOTD
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)changeUserPermissionPacket:(unsigned int)level forSID:(NSData *)sid andUser:(unsigned int)uID{
	if( level == 0 ) return nil;
	if( uID   == 0 ) return nil;
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CF9] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:uID] forKey:@"0x18"]; // the user ID
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:level] forKey:@"0x13"]; // the level
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}

+ (id)kickUserPacket:(unsigned int)uID forSID:(NSData *)sid{
	if( uID   == 0         ) return nil;
	if( [sid length] != 21 ) return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	XFPacketDictionary *msg = [XFPacketDictionary map];
	[pkt setPacketID:0x19]; // 25
	
	// set its attributes
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:0x4CFB] forKey:@"climsg"];
	
	[msg setObject:[XFPacketAttributeValue attributeValueWithDid:sid]  forKey:@"0x04"]; // group chat SID
	[msg setObject:[XFPacketAttributeValue attributeValueWithInt:uID] forKey:@"0x18"]; // the user ID
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithAttributeMap:msg] forKey:@"msg"];
	
	[pkt generate];
	return pkt;
}



//*******************************************************************************************************
// Peer To Peer File transfer packets
//*******************************************************************************************************
#pragma mark -
#pragma mark P2P File transfer packet templates

+ (id)requestFileTransferPacket:(unsigned int)p_fileID fileName:(NSString *)p_fileName description:(NSString *)p_desc fileSize:(unsigned long)p_size modificationTime:(unsigned int)p_mTime
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	/*	AttrMap {
	 fileid = [[ Packet Attribute, type = 2, arrType = -1, value = 2147483649 ]]
	 filename = [[ Packet Attribute, type = 1, arrType = -1, value = "5.98.jpg" ]]
	 desc = [[ Packet Attribute, type = 1, arrType = -1, value = "" ]]
	 size = [[ Packet Attribute, type = 7, arrType = -1, value = 205457 ]]
	 mtime = [[ Packet Attribute, type = 2, arrType = -1, value = 1297791850 ]]
	 } 
	 */
	[pkt setPacketID:XFClientP2PFileTransferRequestPacketID];
	[pkt setIsJumbo:YES];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_fileID]		forKey:@"fileid"	];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:p_fileName]	forKey:@"filename"	];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithString:p_desc]		forKey:@"desc"		];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt64:p_size]		forKey:@"size"		];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_mTime]		forKey:@"mtime"		];
	
	[pkt generate];
	return pkt;
}

+ (id)fileTransferReply:(unsigned int)p_fileID reply:(unsigned char)p_reply
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID:XFClientP2PFileTransferRequestReplyPacketID];
	[pkt setIsJumbo:YES];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_fileID] forKey:@"fileid"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithByte:p_reply] forKey:@"reply"];
	
	[pkt generate];
	
	return pkt;
}

+ (id)fileTransferEventPacket:(unsigned int)p_fileID event:(unsigned char)p_event
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID:XFClientP2PFileTransferEventPacketID];
	[pkt setIsJumbo:YES];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_fileID] forKey:@"fileid"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithByte:p_event] forKey:@"event"];
	
	[pkt generate];
	
	return pkt;
}

+ (id)fileTransferCompletedPacket:(unsigned int)p_fileid
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setPacketID:XFClientP2PFileTransferCompletePacketID];
	[pkt setIsJumbo:YES];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_fileid] forKey:@"fileid"];
	
	[pkt generate];
	
	return pkt;
}

/*
 2011-02-15 21:47:34.822 BlackFire[7801:903] XFUDP32Packet: packet: packet:  ID 16008, 2 attrs
 AttrMap {
 fileid = [[ Packet Attribute, type = 2, arrType = -1, value = 2147483648 ]]
 reply = [[ Packet Attribute, type = 8, arrType = -1, value = 1 ]]
 }
 
 */

/*
 
 packet:  ID 16014, 3 attrs
 AttrMap {
 fileid = [[ Packet Attribute, type = 2, arrType = -1, value = 2147483648 ]]
 event = [[ Packet Attribute, type = 2, arrType = -1, value = 1 ]]
 type = [[ Packet Attribute, type = 2, arrType = -1, value = 1 ]]
 }
 EVENT 1 TYPE 2 = cancelled
 DONT KNOW WHAT OTHER TYPES ARE
 */

+ (id)fileTransferDataRequestPacket:(unsigned int)p_fileID offset:(unsigned long long)p_offset size:(unsigned int)p_size msgID:(unsigned int)p_msgID
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setIsJumbo:YES];
	[pkt setPacketID:XFClientP2PFileTransferDataRequestPacketID];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_fileID] forKey:@"fileid"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt64:p_offset] forKey:@"offset"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_size] forKey:@"size"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_msgID] forKey:@"msgid"];
	
	[pkt generate];
	return pkt;
}

/*
 
 2011-02-15 21:47:43.433 BlackFire[7801:903] P2P File transfer data request packet: packet:  ID 16011, 4 attrs
 AttrMap {
 fileid = [[ Packet Attribute, type = 2, arrType = -1, value = 2147483648 ]]
 offset = [[ Packet Attribute, type = 7, arrType = -1, value = 40960 ]]
 size = [[ Packet Attribute, type = 2, arrType = -1, value = 1024 ]]
 msgid = [[ Packet Attribute, type = 2, arrType = -1, value = 92 ]]
 }
 
 
 */

/*
 fileid = [[ Packet Attribute, type = 2, arrType = -1, value = 2147483651 ]]
 offset = [[ Packet Attribute, type = 7, arrType = -1, value = 0 ]]
 size = [[ Packet Attribute, type = 2, arrType = -1, value = 1024 ]]
 data = [[ Packet Attribute, type = 4, arrType = 8, value = (
 */

+ (id)fileTransferDataPacket:(unsigned int)p_fileid offset:(unsigned int)p_offset size:(unsigned int)p_size data:(NSArray *)p_data
{
	if( p_fileid == 0 )
		return nil;
	if( p_offset > p_size )
		return nil;
	if( p_size == 0 )
		return nil;
	if( ! p_data )
		return nil;
	
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	[pkt setIsJumbo:YES];
	
	[pkt setPacketID:XFClientP2PFileTransferDataPacketID];
	
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_fileid] forKey:@"fileid"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt64:p_offset] forKey:@"offset"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithInt:p_size] forKey:@"size"];
	[pkt setAttribute:[XFPacketAttributeValue attributeValueWithArray:p_data] forKey:@"data"];
	
	
	
	[pkt generate];
	return pkt;
}


#if 0
+ (id)template
{
	XFPacket *pkt = [[[XFPacket alloc] init] autorelease];
	
	[pkt setPacketID: 0x00];
	
	[pkt generate];
	return pkt;
}
#endif
- (id)init
{
	if( (self = [super init]) )
	{
		_packetID   = 0;
		_attributes = [[XFPacketDictionary alloc] init];
		_data        = nil;
	}
	return self;
}

- (void)setAttribute:(id)value forKey:(id)aKey
{
	[_attributes setObject:value forKey:aKey];
}

#if 0
- (void)removeAttributeForKey:(NSString *)aKey
{
	[_attributes removeObjectForKey:aKey];
}
#endif

- (BOOL)generate
{
	
	if( [[self attributes] count] > 0 )
	{
		//XFPacketGenerator *generator = [XFPacketGenerator generatorWithID:[self packetID] attributes:[self attributes]];
		
		@try
		{
			[self generatePacket];
			return YES;
		}
		@catch( NSException *e )
		{
			NSLog(@"Error generating packet data (%@)",e);
			return NO;
		}
	}
    
	
	return NO;
}

@end


