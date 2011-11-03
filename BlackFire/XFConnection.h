//
//  XFConnection.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Socket.h"

@class XFSession, XFPacket, XFFriend, XFGroup;

typedef enum
{
	XFConnectionDisconnected = 0,
	XFConnectionStarting,
	XFConnectionConnected,
	XFConnectionStopping
} XFConnectionStatus;

@interface XFConnection : NSObject <SocketDelegate>
{
	XFSession			*_session;
	Socket				*_socket;
	NSMutableData		*_availableData;
	NSTimer				*_keepAliveResponseTimer;
	
	XFConnectionStatus	_status;
}

@property (readonly) XFConnectionStatus status;

- (id)initWithSession:(XFSession *)session;

//--------------------------------------------------------------
// Connecting

- (void)connect;
- (void)disconnect;
- (void)connectionTimedOut;

//--------------------------------------------------------------
// Sending and receiving data

- (void)sendData:(NSData *)data;
- (void)receivedData:(NSData *)data;
- (void)sendPacket:(XFPacket *)packet;

//--------------------------------------------------------------
// Keep alive

- (void)sendKeepAliveRequest;
- (void)keepAliveResponseTimeout:(NSTimer *)aTimer;

//--------------------------------------------------------------
// Processing packets

- (BOOL)processPacket:(XFPacket *)packet;

// Specific packet processors
- (void)processLoginPacket:(XFPacket *)pkt;
- (void)processLoginSuccessPacket:(XFPacket *)pkt;
- (void)processVersionTooOldPacket:(XFPacket *)pkt;
- (void)processFriendsListPacket:(XFPacket *)pkt;
- (void)processSessionIDPacket:(XFPacket *)pkt;
- (void)processFriendStatusPacket:(XFPacket *)pkt;
- (void)processGameStatusPacket:(XFPacket *)pkt;
- (void)processFriendOfFriendPacket:(XFPacket *)pkt;
- (void)processNicknameChangePacket:(XFPacket *)pkt;
- (void)processSearchResultsPacket:(XFPacket *)pkt;
- (void)processRemoveFriendPacket:(XFPacket *)pkt;
- (void)processFriendRequestPacket:(XFPacket *)pkt;
- (void)processFriendGroupNamePacket:(XFPacket *)pkt;
- (void)processFriendGroupMemberPacket:(XFPacket *)pkt;
- (void)processFriendGroupListPacket:(XFPacket *)pkt;
- (void)processUserOptionsPacket:(XFPacket *)pkt;
- (void)processChatMessagePacket:(XFPacket *)pkt;
- (void)processDisconnectPacket:(XFPacket *)pkt;
- (void)processKeepAliveResponse:(XFPacket *)pkt;
- (void)processInvitSend:(XFPacket *)pkt;

- (void)processFriendChangePacket:(XFPacket *)pkt;

- (void)processClanListPacket:(XFPacket *)pkt;
- (void)processClanMembersPacket:(XFPacket *)pkt;

// TODO: Fix this
//- (void)raiseFriendNotification:(XFFriend *)aFriend attribute:(XFFriendChangeAttribute)attr;

- (void)processBroadCastPacket:(XFPacket *)pkt;

- (void)processChatRoomMotdChanged:(XFPacket *)pkt;
- (void)processChatRoomNameChanged:(XFPacket *)pkt;
- (void)processChatRoomUserLevelChanged:(XFPacket *)pkt;
- (void)processChatRoomUserGotKickedPacket:(XFPacket *)pkt;
- (void)processChatRoomAccessChangedPacket:(XFPacket *)pkt;
- (void)processChatRoomPasswordChangedPacket:(XFPacket *)pkt;
- (void)processSystemBroadcast:(XFPacket *)pkt;
- (void)processChatRoomInvite:(XFPacket *)pkt;
- (void)processChatRoomJoinInfo:(XFPacket *)pkt;
- (void)processChatRoomMessage:(XFPacket *)pkt;
- (void)processMemberJoined:(XFPacket *)pkt;
- (void)processMemberLeft:(XFPacket *)pkt;
- (void)processChatRoomMembers:(XFPacket *)pkt;

- (void)processServerList:(XFPacket *)pkt;

- (void)processFriendAvatarPacket:(XFPacket *)pkt;


//--------------------------------------------------------------
// Sending packets

// Stuff you can only do on the log-in connection (to the Xfire master server)
- (void)sendNetworkInfoPacketWithIP:(unsigned int)ip andNATType:(unsigned int)natType;
- (void)setGameStatus:(unsigned)gameID gameIP:(unsigned)gip gamePort:(unsigned)gp;
- (void)setStatusText:(NSString *)text;
- (void)changeNickname:(NSString *)text;
- (void)beginUserSearch:(NSString *)searchString;
- (void)sendFriendInvitation:(NSString *)username message:(NSString *)msg;
- (void)sendRemoveFriend:(XFFriend *)fr;
- (void)acceptFriendRequest:(XFFriend *)fr;
- (void)declineFriendRequest:(XFFriend *)fr;
- (void)addCustomFriendGroup:(NSString *)groupName;
- (void)renameCustomFriendGroup:(unsigned)groupID newName:(NSString *)groupName;
- (void)removeCustomFriendGroup:(unsigned)groupID;
- (void)addFriend:(XFFriend *)fr toGroup:(XFGroup *)group;
- (void)removeFriend:(XFFriend *)fr fromGroup:(XFGroup *)group;
// TODO: Implement user options
//- (void)setUserOptions:(EXBlist *)options;
- (void)createNewChatRoom:(NSString *)name andPassword:(NSString *)password;

- (void)addFavoriteServer:(unsigned int)gameID withIP:(NSString *)ip andPort:(NSString *)port;
- (void)removeFavoriteServer:(unsigned int)gameID withIP:(NSString *)ip andPort:(NSString *)port;

- (void)requestFriendInfo:(unsigned int)userID;

@end
