/*******************************************************************
	FILE:		XFPacketAttributeValue.h
	
	DESCRIPTION:
		Represents a value in an XFPacketDictionary.  The only
		reason this class exists is to ensure that array types are
		correct when sent packets have empty arrays.  It's a CYA in
		case the Xfire master server requires correct types keys for
		attribute values.  Otherwise it is just a wrapper around
		the various Cocoa types that represent values in Xfire packets.

*******************************************************************/

#import <Foundation/Foundation.h>

#define XFPacketAttributeInvalidType         (-1)
#define XFPacketAttributeStringType          (0x01) /* NSString */
#define XFPacketAttributeUInt32Type          (0x02) /* NSNumber(unsigned int) */
#define XFPacketAttributeUUIDType            (0x03) /* NSData(16) */
#define XFPacketAttributeArrayType           (0x04) /* NSArray */
#define XFPacketAttributeStringAttrMapType   (0x05) /* XFPacketDictionary */
#define XFPacketAttributeDIDType             (0x06) /* NSData(21) */
#define XFPacketAttributeUInt64Type          (0x07) /* NSNumber(unsigned long long) */
#define XFPacketAttributeUInt8Type           (0x08) /* NSNumber(unsigned char) */
#define XFPacketAttributeIntAttrMapType      (0x09) /* XFPacketDictionary */
#define XFPacketAttributeDataType			 (0x10) /* Data -- for file transfers */

@class XFPacketDictionary;

@interface XFPacketAttributeValue : NSObject
{
	id  _value;
	int _typeID;
	int _arrayElementType; // only useful for arrays, otherwise undefined
}

@property (unsafe_unretained, readonly) id		value;
@property (readonly) int	typeID;
@property (readonly) int	arrayElementType;

+ (id)attributeValueWithString:(NSString *)str;
+ (id)attributeValueWithInt:(unsigned int)val;
+ (id)attributeValueWithInt64:(unsigned long long)val;
+ (id)attributeValueWithByte:(unsigned char)val;
+ (id)attributeValueWithNumber:(NSNumber *)nbr; // should be unsigned int anyway
+ (id)attributeValueWithUUID:(NSData *)uuid; // 16 byte
+ (id)attributeValueWithDid:(NSData *)did;
+ (id)attributeValueWithData:(NSData *)data;
+ (id)attributeValueWithArray:(NSArray *)arr;
+ (id)attributeValueWithArray:(NSArray *)arr emptyElementType:(int)et;
+ (id)attributeValueWithAttributeMap:(XFPacketDictionary *)map;

- (id)initWithValue:(id)aVal typeID:(int)tid arrayType:(int)atid;
/*- (int)typeID;
- (id)value;
- (int)arrayElementType;
 // replaced by @properties
 */

@end
