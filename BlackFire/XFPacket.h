//
//  XFFriend.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 Exurion. All rights reserved.
//
//	Represents an Xfire data packet, can generate and scan data
//	for you.

#import <Foundation/Foundation.h>

typedef unsigned int XFPacketID;

@class XFPacketDictionary, XFPacketAttributeValue;

// -------------------------------------------------------------------------
// Packet dictionary entry keys
// -------------------------------------------------------------------------

// NOTES:
// 1. As a general rule, most attributes can be either the type specified or
//    an NSArray of the specified type.  Exceptions are noted.
// 2. When an NSDictionary is specified, that dictionary must consist of the
//    same kinds of data (the keys below with associated values).
// 3. All strings must be convertible to UTF-8.
// 4. Jumbo packets are packets with a bigger header file, and they are used for
//	  file transfers. Some file transfer packets are handled in an inefficient way,
//	  the data is returned in an array, and therefore it is very CPU intensive to get all
//	  your data out, therefore a small workaround for the certain packet type was made: this is not
//	  a decent solution and should be patched

// Key											Valid Value Type(s)
// -----------------------------------------	--------------------------
extern NSString * const XFPacketChecksumKey;		// NSString
extern NSString * const XFPacketChunksKey;			// NSNumber <XFUInteger32>
extern NSString * const XFPacketEmailKey;			// NSString
extern NSString * const XFPacketFirstNameKey;		// NSString
extern NSString * const XFPacketFlagsKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketFriendsKey;			// NSString
extern NSString * const XFPacketFriendSIDKey;		// NSData<16>
extern NSString * const XFPacketGameIDKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketGameIPKey;			// NSNumber<XFUInteger32> (XFIPAddress)
extern NSString * const XFPacketGamePortKey;		// NSNumber<XFUInteger32>
extern NSString * const XFPacketIMKey;				// NSString
extern NSString * const XFPacketIMIndexKey;			// NSNumber<XFUInteger32>

extern NSString * const XFPacketTypingKey;			// NSNumber<XFUInteger32>

extern NSString * const XFPacketLanguageKey;		// NSString
extern NSString * const XFPacketLastNameKey;		// NSString
extern NSString * const XFPacketMessageKey;			// NSString
extern NSString * const XFPacketMessageTypeKey;		// NSNumber<XFUInteger32>
extern NSString * const XFPacketNameKey;			// NSString    (username)
extern NSString * const XFPacketNickNameKey;		// NSString
extern NSString * const XFPacketPartnerKey;			// NSString
extern NSString * const XFPacketPasswordKey;		// NSString    (of hashed password, not an array)
extern NSString * const XFPacketPeerMessageKey;		// NSDictionary
// value is an NSDictionary of the following keys:
//   XFPacketMessageTypeKey
//   XFPacketIMIndexKey
//   XFPacketIMKey

extern NSString * const XFPacketReasonKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketSaltKey;			// NSString/NSData  (no arrays)
extern NSString * const XFPacketSessionIDKey;		// NSData      (16 bytes, a UUID)
extern NSString * const XFPacketSkinKey;			// NSString
extern NSString * const XFPacketStatsKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketStatusKey;			// NSNumber<XFUInteger32>, NSDictionary
// TBD valid keys when it's an NSDictionary
//   XFPacketStatusTextKey ?

extern NSString * const XFPacketThemeKey;			// NSString
extern NSString * const XFPacketUserIDKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketValueKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketVersionKey;			// NSNumber<XFUInteger32>


extern NSString * const XFPacketCommandKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketFileKey;			// NSString
extern NSString * const XFPacketFileIDKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketPrefsKey;			// NSDictionary
extern NSString * const XFPacketResultKey;			// NSNumber<XFUInteger32>
extern NSString * const XFPacketStatusTextKey;		// NSString
extern NSString * const XFPacketTypeKey;			// NSNumber<XFUInteger32>

extern NSString * const XFPacketConnectionKey;
extern NSString * const XFPacketNATKey;
extern NSString * const XFPacketSecKey;
extern NSString * const XFPacketClientIPKey;
extern NSString * const XFPacketNATErrKey;
extern NSString * const XFPacketUPNPInfoKey;

extern NSString * const XFPacketDownloadSetKey;		// NSString
extern NSString * const XFPacketPeerToPeerSetKey;
extern NSString * const XFPacketClientSetKey;
extern NSString * const XFPacketMinRectKey;
extern NSString * const XFPacketMaxRectKey;
extern NSString * const XFPacketCTryKey;

extern NSString * const XFPacketNAT1Key;
extern NSString * const XFPacketNAT2Key;
extern NSString * const XFPacketNAT3Key;

extern NSString * const XFPacketPublicIPKey;

extern NSString * const XFPacketClientMessageKey;
extern NSString * const XFPacketDownloadIDKey;

extern NSString * const XFPacketIPKey;
extern NSString * const XFPacketPortKey;
extern NSString * const XFPacketLocalIPKey;
extern NSString * const XFPacketLocalPortKey;

extern NSString * const XFPacketFilenameKey;
extern NSString * const XFPacketDescriptionKey;
extern NSString * const XFPacketSizeKey;
extern NSString * const XFPacketMessageTimeKey;
extern NSString * const XFPacketReplyKey;
extern NSString * const XFPacketOffsetKey;
extern NSString * const XFPacketChunkCountKey;
extern NSString * const XFPacketMessageIDKey;
extern NSString * const XFPacketDataKey;



enum {
	XFClientLoginPacketID							= 1,	//	0x01
	XFClientChatPacketID							= 2,	//	0x02
	XFClientVersionPacketID							= 3,	//	0x03
	XFClientSetGameStatusPacketID					= 4,	//	0x04
	XFClientMoreFriendInfoPacketID					= 5,	//	0x05
	XFClientSendFriendRequestPacketID				= 6,	//	0x06
	XFClientAcceptFriendRequestPacketID				= 7,	//	0x07
	XFClientDeclineFriendRequestPacketID			= 8,	//	0x08
	XFClientRemoveFriendPacketID					= 9,	//	0x09
	XFClientPrefsPacketID							= 10,	//	0x0a
	XFClientUserSearchPacketID						= 12,	//	0x0c
	XFClientKeepAlivePacketID						= 13,	//	0x0d
	XFClientChangeNickNamePacketID					= 14,	//	0x0e
	XFClientVOIPSoftwareStatusPacketID				= 15,	//	0x0f
	XFClientInfoPacketID							= 16,	//	0x10
	XFClientNetworkInfoPacketID						= 17,	//	0x11
	XFClientAddFavoriteGameServerPacketID			= 19,	//	0x13
	XFClientRemoveFavoriteGameServerPacketID		= 20,	//	0x14
	XFClientFriendsGameServerListPacketID			= 21,	//	0x15
	XFClientGameServerListPacketID					= 22,	//	0x16
	XFClientDownloadInfoPacketID					= 23,	//	0x17
	XFClientDownloadInfo2PacketID					= 24,	//	0x18
	XFClientGroupChatPacketID						= 25,	//	0x19
	XFClientAddGroupPacketID						= 26,	//	0x1a
	XFClientRemoveGroupPacketID						= 27,	//	0x1b
	XFClientRenameGroupPacketID						= 28,	//	0x1c
	XFClientAddFriendToGroupPacketID				= 29,	//	0x1d
	XFClientRemoveFriendFromGroupPacketID			= 30,	//	0x1e
	XFClientStatusTextChangePacketID				= 32,	//	0x20
	XFClientRequestInfoViewContentPacketID			= 37,	//	0x25
	XFClientBroadcastInfoChangePacketID				= 38,	//	0x26
	
	XFLoginRequestPacketID							= 128,	//	0x80
	XFLoginFailurePacketID							= 129,	//	0x81
	XFLoginSuccessPacketID							= 130,	//	0x82
	XFFriendsListPacketID							= 131,	//	0x83
	XFSessionIDPacketID								= 132,	//	0x84
	XFChatPacketID									= 133,	//	0x85
	XFVersionTooOldPacketID							= 134,	//	0x86
	XFGameStatusPacketID							= 135,	//	0x87
	XFFriendOfFriendPacketID						= 136,	//	0x88
	XFInvitationResultPacketID						= 137,	//	0x89
	XFFriendRequestPacketID							= 138,	//	0x8a
	XFRemoveFriendPacketID							= 139,	//	0x8b
	XFPrefsPacketID									= 141,	//	0x8d
	XFSearchResultsPacketID							= 143,	//	0x8f
	XFKeepAliveResponsePacketID						= 144,	//	0x90
	XFSignedOnFromOtherLocationPacketID				= 145,	//	0x91
	XFFriendVOIPSoftwarePacketID					= 147,	//	0x93
	XFFavoriteServerListPacketID					= 148,	//	0x94
	XFFriendsFavoriteServerListPacketID				= 149,	//	0x95
	XFServerListPacketID							= 150,	//	0x96
	XFGroupsPacketID								= 151,	//	0x97
	XFGroupMembersPacketID							= 152,	//	0x98
	XFAddGroupConfirmationPacketID					= 153,	//	0x99
	XFFriendStatusPacketID							= 154,	//	0x9a
	XFGroupChatsPacketID							= 155,	//	0x9b
	XFGameClientDataPacketID						= 156,	//	0x9c
	XFScreenshotInfoPacketID						= 157,	//	0x9d
	XFClanGroupsPacketID							= 158,	//	0x9e
	XFClanGroupMembersPacketID						= 159,	//	0x9f
	XFClanGroupMemberLeftPacketID					= 160,	//	0xa0
	XFNickNameChangePacketID						= 161,	//	0xa1
	XFClanGroupMemberNickNameChangePacketID			= 162,	//	0xa2
	XFClanGroupOrderPacketID						= 163,	//	0xa3
	XFClanInvitePacketID							= 165,	//	0xa5
	XFSystemBroadcastPacketID						= 169,	//	0xa9
	XFClanEventsPacketID							= 170,	//	0xaa
	XFClanEventDeletedPacketID						= 171,	//	0xab
	XFFriendsScreenshotsInfoPacketID				= 172,	//	0xac
	XFFriendsExtendedInfoPacketID					= 173,	//	0xad
	XFAvatarInfoPacketID							= 174,	//	0xae
	XFWrongCentralServerIPAddressPacketID			= 175,	//	0xaf
	XFClanGroupMemberInfoPacketID					= 176,	//	0xb0
	XFClanGroupNewsPacketID							= 177,	//	0xb1
	XFVideoInfoPacketID								= 179,	//	0xb3
	XFFriendsVideoInfoPacketID						= 182,	//	0xb6
	XFExternalGameInfoPacketID						= 183,	//	0xb7
	XFFriendBroadcastInfoPacketID					= 184,	//	0xb8
	XFSocialNetworkListPacketID						= 187,	//	0xbb
    XFClanServerListPacketID                        = 188,
	XFContestInfoPacketID							= 191,	//	0xbf
	
	XFGroupChatRoomNameChangedPacketID				= 350,	//	0x15e
	XFGroupChatJoinInfoPacketID						= 351,	//	0x15f
	XFGroupChatUserJoinedPacketID					= 353,	//	0x161
	XFGroupChatUserLeftPacketID						= 354,	//	0x162
	XFGroupChatMessagePacketID						= 355,	//	0x163
	XFGroupChatInvitePacketID						= 356,	//	0x164
	XFGroupChatUserRankChangedPacketID				= 357,	//	0x165
	XFGroupChatPersistentInfoPacketID				= 358,	//	0x166
	XFGroupChatUserKickedPacketID					= 359,	//	0x167
	XFGroupChatVoiceChatStatusChangedPacketID		= 360,	//	0x168
	XFGroupChatForceSavedRoomPacketID				= 361,	//	0x169
	XFGroupChatVoiceChatHostInfoPacketID			= 363,	//	0x16b
	XFGroupChatUserLeftVoiceChatPacketID			= 365,	//	0x16d
	XFGroupChatUserJoinedVoiceChatPacketID			= 367,	//	0x16f
	XFGroupChatInfoPacketID							= 368,	//	0x170
	XFGroupChatDefaultUserRankChangedPacketID		= 370,	//	0x172
	XFGroupChatMessageOfTheDayChangedPacketID		= 374,	//	0x176
	XFGroupChatAllowVoiceChatChangedPacketID		= 375,	//	0x177
	XFGroupChatVoiceChatSessionInfoPacketID			= 383,	//	0x17f
	XFGroupChatRoomNameAvailabilityPacketID			= 384,	//	0x180
	XFGroupChatPasswordChangedPacketID				= 385,	//	0x181
	XFGroupChatDomainChangedPacketID				= 386,	//	0x182
	XFGroupChatRejectConfirmationPacketID			= 387,	//	0x183
	XFGroupChatSilencedChangedPacketID				= 388,	//	0x184
	XFGroupChatShowJoinLeaveMessagesChangedPacketID	= 389,	//	0x185
	
	XFDownloadIdentifierPacketID					= 400,	//	0x190
	XFDownloadPeerInfoPacketID						= 401,	//	0x191
	XFDownloadPeerListPacketID						= 402,	//	0x192
	XFDownloadFileInformationPacketID				= 404,	//	0x194
	XFDownloadFileInformation2PacketID				= 406,	//	0x196
	XFDownloadNewChannelPacketID					= 450,	//	0x1c2
	XFDownloadNewFilesOnChannelPacketID				= 451,	//	0x1c3
	XFDownloadFileChecksumPacketID					= 452,	//	0x1c4
	
	
	// the following are used in peer-to-peer chats
	
	XFClientP2PFileTransferRequestPacketID			= 16007,	// 0x3e87
	XFClientP2PFileTransferRequestReplyPacketID		= 16008,	// 0x3e88
	XFClientP2PFileTransferInfoPacketID				= 16009,	// 0x3e89
	XFClientP2PFileTransferChunkInfoPacketID		= 16010,	// 0x3e8a
	XFClientP2PFileTransferDataRequestPacketID		= 16011,	// 0x3e8b
	XFClientP2PFileTransferDataPacketID				= 16012,	// 0x3e8c
	XFClientP2PFileTransferCompletePacketID			= 16013,	// 0x3e8d
	XFClientP2PFileTransferEventPacketID			= 16014 	// 0x3e8e
  
};


enum {
	XFIntegerKeyUserID								= 0x01,	//	1
	XFIntegerKeyNameID								= 0x02,	//	2 -- can be userName or groupName depending on context
	XFIntegerKeyChatID								= 0x04,	//	4
	XFIntegerKeyMessageID							= 0x05,	//	5
	XFIntegerKeyNickNameID							= 0x0d,	//	13
	XFIntegerKeyGroupID								= 0x19,	//	25
	XFIntegerKeyGroupLongNameID						= 0x1a,	//	26
	XFIntegerKeyGameID								= 0x21,	//	33
	XFIntegerKeyStatusTextID						= 0x2e,	//	46
	XFIntegerKeyClanGroupTypeID						= 0x34,	//	52
	XFIntegerKeyUserOptionsID						= 0x4c,	//	76
	XFIntegerKeyScreenshotCaptionID					= 0x54,	//	84
	XFIntegerKeyClanGroupID							= 0x6c,	//	108
	XFIntegerKeyClanGroupUserNickNameID				= 0x6d,	//	109
	XFIntegerKeyClanGroupShortNameID				= 0x72,	//	
	XFIntegerKeyClanGroupLongNameID					= 0x81,	//	
	XFIntegerKeyClanGroupIsUnlimitedGroupTypeID		= 0xb0	//	
};

enum {
	XFPrefsGameStatusShowMyFriends							= 0x01,	//	
	XFPrefsGameStatusShowGameServerData						= 0x02,	//
	XFPrefsGameStatusShowOnMyProfile						= 0x03,	//
	XFPrefsPlaySoundWhenSendOrReceiveMessage				= 0x04,	// 
	XFPrefsPlaySoundWhenReceiveMessageInGame				= 0x05,	// 
	XFPrefsShowChatTimeStamps								= 0x06,	//
	XFPrefsPlaySoundWhenFriendLogsOnOrOff					= 0x07,	// 
	XFPrefsGameStatusShowFriendsOfFriends					= 0x08,	//
	XFPrefsShowOfflineFriends								= 0x09,	//
	XFPrefsShowNickNames									= 0x0a,	//
	XFPrefsShowVoiceChatServer								= 0x0b,	//
	XFPrefsShowWhenIType									= 0x0c,	//
	XFPrefsShowBalloonTooltipWhenFriendLogsOnOrOff			= 0x10,	//
	XFPrefsShowBalloonTooltipWhenDownloadStartsOrFinishes	= 0x11, //
	XFPrefsPlaySoundWhenSomeoneJoinsOrLeavesChatroom		= 0x12,	//
	XFPrefsPlaySoundWhenSendOrReceiveVoiceChatRequests		= 0x13, //
	XFPrefsPlaySoundWhenTakingScreenshotInGame				= 0x14	//
};


enum {
	XFClientGroupChatJoinID									= 0x4cf4, // 19700
	XFClientGroupChatLeaveID								= 0x4cf5, // 19701
	XFClientGroupChatMessageID								= 0x4cf6, // 19702
	XFClientGroupChatNewInviteID							= 0x4cf7, // 19703
	XFClientGroupChatChangeRoomNameID						= 0x4cf8, // 19704
	XFClientGroupChatChangeUserPermissionsID				= 0x4cf9, // 19705
	XFClientGroupChatRequestPersistentInfoID				= 0x4cfa, // 19706
	XFClientGroupChatKickUserID								= 0x4cfb, // 19707
	XFClientGroupChatInviteID								= 0x4cfc, // 19708
	XFClientGroupChatSaveChatroomID							= 0x4cfd, // 19709
	XFClientGroupChatChangeVoiceChatEnabledID				= 0x4cfe, // 19710
	XFClientGroupChatRejectInvitationID						= 0x4cff, // 19711
	XFClientGroupChatStartVoiceChatUseMeAsHostID			= 0x4d00, // 19712
	XFClientGroupChatJoinGroupVoiceChatID					= 0x4d01, // 19713		// This is sent to the server to join a voice chat hosted by another user
	XFClientGroupChatLeaveGroupVoiceChatID					= 0x4d02, // 19714
	XFClientGroupChatForceVoiceOffDeprecatedID				= 0x4d04, // 19716
	XFClientGroupChatHostGroupVoiceChatID					= 0x4d05, // 19717
	XFClientGroupChatExtendedInfoID							= 0x4d06, // 19718
	XFClientGroupChatSetDefaultUserPermissionsID			= 0x4d08, // 19720
	XFClientGroupChatChangeMessageOfTheDayID				= 0x4d0c, // 19724
	XFClientGroupChatChangeVoiceChatAllowedID				= 0x4d0d, // 19725
	XFClientGroupChatJoinVoiceChatSessionID					= 0x4d11, // 19729
	XFClientGroupChatIsRoomNameAvailableID					= 0x4d14, // 19732
	XFClientGroupChatChangePasswordID						= 0x4d15, // 19733
	XFClientGroupChatChangeAccessTypeID						= 0x4d16, // 19734
	XFClientGroupChatChangeSilencedID						= 0x4d17, // 19735
	XFClientGroupChatChangeShowJoinLeaveMessagesID			= 0x4d18  // 19736
};


#pragma pack(1)

typedef enum  {
	XFAttributeKeyStringDomain  = 1,
	XFAttributeKeyIntegerDomain
} XFAttributeKeyDomain;


@interface XFPacket : NSObject
{
	XFPacketDictionary	*_attributes;
	NSMutableData		*_data;
	const unsigned char *_bytes;
	
	NSUInteger			_len;
	XFPacketID			_packetID;
	unsigned int		_idx;
	
	BOOL				isJumbo;
}

@property (nonatomic, retain) XFPacketDictionary *attributes;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, assign) BOOL isJumbo;
@property (nonatomic, assign) XFPacketID packetID;


//------------------------------------------------------------------
// Decode a serialized packet
// Used when receiving a packet
+ (XFPacket *)decodedPacketByScanningBuffer:(NSData *)data;
+ (XFPacket *)decodedJumboPacketByScanningBuffer:(NSData *)data;

//------------------------------------------------------------------
// Accessors
- (id)attributeForKey:(id)key;

// Compound accessor utility to get all values into an array, regardless of
// whether the packet has a single item or multiple items
- (NSArray *)attributeValuesForKey:(id)key;


//-----------------------------------------------------------------------------------
// Packet scanner
// initialize a scanner with some data
- (id)initWithID:(XFPacketID)pktID attributeMap:(XFPacketDictionary *)attrs raw:(NSData *)raw isJumbo:(BOOL)jumbo;
//+ (id)scannerWithData:(NSData *)data;
//- (id)initWithData:(NSData *)data;

// Top level packet scan
// outputs are packetID and attribute map
- (XFPacket *)scan:(NSData *)data;





//-----------------------------------------------------------------------------------
// Private methods: DO NOT TOUCH


- (void)raiseException:(NSString *)desc;

// Scan a collection of attributes (key/value pairs)

- (XFPacketDictionary *)scanAttributeMapInDomain:(XFAttributeKeyDomain)domain;
- (XFAttributeKeyDomain)keyDomainForPacketType:(unsigned short)type;

// Scan an individual attribute

- (void)scanAttribute:(NSString **)keyOut keyDomain:(XFAttributeKeyDomain)domain value:(id *)valueOut;

//- (XFPacketDictionary *)scanAttributes:(unsigned int)count binaryDeyDomain:(BOOL)binaryKeyDomain;
- (id)scanAttributeValue; // scans just value
- (NSArray *)scanArray;

// Primitive Scanners

- (unsigned char)scanUInt8;
- (unsigned short)scanUInt16;
- (unsigned int)scanUInt32;
- (unsigned long long)scanUInt64;
- (NSData *)scanUUID; // well, a 16 byte/128 bit value, anyway
- (NSString *)scanAttrKeyString;
- (NSString *)scanString;

- (NSData *)scanDataOfLength:(unsigned int)len;

// same as scanUInt8, but doesn't remove from the buffer
// used to peek ahead a little to make a decision, but leave the data to be consumed later
// it assumes we expect a byte to be available
- (unsigned char)peekUInt8;

// Other

- (BOOL)isAtEnd;



//------------------------------------------------------------------------------------------
// Packet generation

- (void)generatePacket;
- (void)generateUInt8:(unsigned char)value;
- (void)generateUInt16:(unsigned short)value;
- (void)generateUInt32:(unsigned int)value;
- (void)generateUUID:(NSData *)uuid; // 16 byte value
- (void)generateString:(NSString *)str;
- (void)generateAttrKeyString:(NSString *)str;
- (void)generateDID:(NSData *)data; // 21 byte value

- (void)generateAttributeMap:(XFPacketDictionary *)attrs;
- (void)generateAttribute:(id)key value:(XFPacketAttributeValue *)val;
- (void)generateArray:(XFPacketAttributeValue *)arr;

- (BOOL)keyStringIsNumber:(NSString *)key;
- (int)intForKeyString:(NSString *)key;

//------------------------------------------------------------------
// Empty packet
+ (id)packet;

//------------------------------------------------------------------
// Generators for Common Packets
// -- Packet templates

// username/password packet (ID 1)
+ (id)loginPacketWithUsername:(NSString *)name password:(NSString *)pass flags:(unsigned int)f;
	// name is username
	// pass is hashed password (generate elsewhere)
	// I don't know what flags might be, so pass 0 for now


+ (id)friendInfoPacket:(unsigned int)userID;

// chat messages (ID 2)
+ (id)chatTypingNotificationPacketWithSID:(NSData *)sid imIndex:(unsigned int)imidx typing:(unsigned int)typing;
	// acknowledge receipt of a chat message
+ (id)chatAcknowledgementPacketWithSID:(NSData *)sid imIndex:(unsigned int)idx;

+ (id)chatPeerToPeerInfoResponseWithSalt:(NSString *)salt sid:(NSData *)sidd;
	// send an instant message
+ (id)chatInstantMessagePacketWithSID:(NSData *)sid imIndex:(unsigned int)idx message:(NSString *)msg;

// client version packet (ID 3)
+ (id)clientVersionPacket:(unsigned int)vers;
	// Not sure what a valid version value is; 82 came from a recent Xfire client

// game status change packet (ID 4)
+ (id)gameStatusChangePacketWithGameID:(unsigned)gid gameIP:(unsigned)gip gamePort:(unsigned)port;

// Friend of Friend info request (ID 5)
+ (id)friendOfFriendRequestPacketWithSIDs:(NSArray *)sessionIDs;
	// pass an array of Session IDs (NSData<16>)
	// do not pass an empty array!

// Add-friend request (ID 6)
+ (id)addFriendRequestPacketWithUserName:(NSString *)un message:(NSString *)msg;

// Accept incoming add-friend request (ID 7)
+ (id)acceptFriendRequestPacketWithUserName:(NSString *)un;

// Decline incoming add-friend request (ID 8)
+ (id)declineFriendRequestPacketWithUserName:(NSString *)un;

// Remove-friend request (ID 9)
+ (id)removeFriendRequestWithUserID:(unsigned int)uid;

// Change user options packet (ID 10)
// Pass options with keys equal to the packet attribute map keys and values as NSNumber.bool
+ (id)changeOptionsPacket;

// user search packet (ID 12)
+ (id)userSearchPacketWithName:(NSString *)name fname:(NSString *)fn lname:(NSString *)ln email:(NSString *)em;
	// pass nil or @"" for fn, ln, and em

// connection keepalive packet (ID 13)
+ (id)keepAlivePacketWithValue:(unsigned)val stats:(NSArray *)stats;
	// pass 0 for val
	// pass [NSArray array] for stats

// Change nickname (ID 14)
+ (id)changeNicknamePacketWithName:(NSString *)nick;

// client information packet (ID 16)
+ (id)clientInfoPacketWithLanguage:(NSString *)lng skin:(NSString *)skn theme:(NSString *)thm partner:(NSString *)prt;
	// pass "us" for language
	// pass "Shadow" for skin
	// pass "default" for theme
	// pass "" for partner

// client network info packet (ID 17)
+ (id)networkInfoPacketWithConn:(unsigned)conn nat:(BOOL)isNat sec:(unsigned)sec ip:(unsigned)ip naterr:(BOOL)nErr uPnPInfo:(NSString *)info;
	// pass 2 for conn (no idea what it means)
	// pass 1 for isNat (assume it's a boolean: are we behind a NAT)
	// pass 5 for sec (no idea what it means)
	// pass local IP address for ip (so, whatever you see)
	// pass 1 for nErr (assume it's a boolean: did we have NAT errors)
	// pass "" for UPnP info (assume it's a configuration string)

// add custom friend group packet (ID 26)
+ (id)addCustomFriendGroupPacketWithName:(NSString *)groupName;

// remove custom friend group packet (ID 27)
+ (id)removeCustomFriendGroupPacket:(unsigned)groupID;

// rename custom friend group packet (ID 28)
+ (id)renameCustomFriendGroupPacket:(unsigned)groupID newName:(NSString *)groupName;

// add friend to custom friend group (ID 29)
+ (id)addFriendPacket:(unsigned)friendID toCustomGroup:(unsigned)groupID;

// remove friend from custom friend group (ID 30)
+ (id)removeFriendPacket:(unsigned)friendID fromCustomGroup:(unsigned)groupID;

// status text change packet (ID 32)
+ (id)statusTextChangePacket:(NSString *)newText;
	// pass @"" or nil to remove status text

// server list
+ (id)addFavoriteServerPacket:(unsigned int)gameID serverIP:(NSString *)ip serverPort:(NSString *)gamePort;
+ (id)removeFavoriteServerPacket:(unsigned int)gameID serverIP:(NSString *)ip serverPort:(NSString *)gamePort;

// Chat room support
+ (id)createNewChatRoom:(NSString *)roomName withPassword:(NSString *)password;
+ (id)inviteFriendToRoomPacket:(NSData *)roomSid withUser:(unsigned int)userID;
+ (id)denyRoomInvitationPacket:(NSData *)roomSid;
+ (id)leaveChatRoomPacket:(NSData*)sid;
+ (id)joinChatRoomPacket:(NSData *)sid withName:(NSString *)roomName andPassword:(NSString *)password;
+ (id)sendChatRoomMessagePacket:(NSData *)sid withMessage:(NSString *)message;
+ (id)changeRoomNamePacket:(NSString *)newName forSID:(NSData *)sid;
+ (id)changeMotdPacket:(NSString *)newMotd forSID:(NSData *)sid;
+ (id)changeUserPermissionPacket:(unsigned int)level forSID:(NSData *)sid andUser:(unsigned int)uID;
+ (id)kickUserPacket:(unsigned int)uID forSID:(NSData *)sid;
+ (id)changeRoomPasswordPacket:(NSString *)newPassword forSID:(NSData *)sid;
+ (id)changeRoomAccessPacket:(BOOL)access forSID:(NSData *)sid;
+ (id)chatRequestPeerToPeerSessionPacketWithFriendSessionID:(NSData *)sessionID
                                            publicIPAddress:(unsigned int)publicIPAddress
                                                 publicPort:(unsigned short)publicPort
                                             localIPAddress:(unsigned int)localIPAddress
                                                  localPort:(unsigned short)localPort
                                                    natType:(unsigned int)natType
                                                       salt:(NSString *)salt;

//------------------------------------------------------------------
// P2P File transfer packet templates

+ (id)requestFileTransferPacket:(unsigned int)p_fileID fileName:(NSString *)p_fileName description:(NSString *)p_desc fileSize:(unsigned long)p_size modificationTime:(unsigned int)p_mTime;
+ (id)fileTransferReply:(unsigned int)p_fileID reply:(unsigned char)p_reply;
+ (id)fileTransferEventPacket:(unsigned int)p_fileID event:(unsigned char)p_event;
+ (id)fileTransferDataRequestPacket:(unsigned int)p_fileID offset:(unsigned long long)p_offset size:(unsigned int)p_size msgID:(unsigned int)p_msgID;
+ (id)fileTransferCompletedPacket:(unsigned int)p_fileid;

//------------------------------------------------------------------
// Accessors

- (void)setPacketID:(XFPacketID)anID;
- (void)setAttribute:(id)value forKey:(id)aKey; // key may be only NSString or NSNumber(int)
//- (void)removeAttributeForKey:(NSString *)aKey;

//------------------------------------------------------------------
// Generate the raw byte stream, that you can then get using -raw
- (BOOL)generate;

@end
