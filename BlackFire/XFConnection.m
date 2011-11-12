//
//  XFConnection.m
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XFConnection.h"
#import "XfireKit.h"
#import "XFSession.h"
#import "XFPacket.h"
#import "XFPacketDictionary.h"

#import "XFGroupChat.h"
#import "XFChat.h"

#import "XFGroupController.h"
#import "XFGroup.h"
#import "XFFriend.h"
#import "XFGameServer.h"

@implementation XFConnection

@synthesize status = _status;
@synthesize session = _session;

- (id)initWithSession:(XFSession *)session
{
	if( (self = [super init]) )
	{
		_session				= session;
		_socket					= nil;
		_availableData			= [[NSMutableData alloc] init];
		_keepAliveResponseTimer = nil;
		
		_status					= XFConnectionDisconnected;
	}
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		_session					= nil;
		_socket						= nil;
		_availableData				= [[NSMutableData alloc] init];
		_keepAliveResponseTimer		= nil;
		
		_status						= XFConnectionDisconnected;
	}
	return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_socket setDelegate:nil];
	[_socket release];
	_socket = nil;
	[_availableData release];
	_availableData = nil;
	_status = XFConnectionDisconnected;
	_session = nil;
	if( [_keepAliveResponseTimer isValid] )
	{
		[_keepAliveResponseTimer invalidate];
		_keepAliveResponseTimer = nil;
	}
	[super dealloc];
}

#pragma mark - Connecting

- (void)connect
{
	if( _status != XFConnectionDisconnected )
		return;
	
	[_socket release]; // prevent leaking
	_socket = nil;
	
	_status			= XFConnectionStarting;
	_socket			= [[Socket alloc] initWithDelegate:self];
	_socket.port	= XFIRE_PORT;
	
	[_socket connectToHost:XFIRE_ADDRESS];
	
	// For the lazy code reader: XFIRE_ADDRESS	= "cs.xfire.com"
	//							 XFIRE_PORT		= 25999
	// Go on, try it with telnet :D
	
	[self performSelector:@selector(connectionTimedOut) withObject:nil afterDelay:10.0f];
}

- (void)disconnect
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if( _keepAliveResponseTimer )
	{
		[_keepAliveResponseTimer invalidate];
		_keepAliveResponseTimer = nil;
	}
	
	[_availableData release];
	_availableData = nil;
	
	_status = XFConnectionDisconnected;
	[_socket release];
	_socket = nil;
}

- (void)connectionTimedOut
{
	// otherwise it does not make any sense to disconnect here.
	if( _status == XFConnectionStarting )
	{
		[_session connection:self willDisconnect:XFConnectionErrorStoppedResponding];
		[self disconnect];
	}
}

- (void)didDisconnectWithReason:(SocketError)reason
{
	[_session connection:self willDisconnect:XFConnectionErrorHungUp];
	
	[self disconnect];
}

- (void)didConnect
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	_status = XFConnectionConnected;
	[self sendData:[@"UA01" dataUsingEncoding:NSUTF8StringEncoding]];
	
	// haha, yeah the xfire server is that dumb. They actually accept this version..
	// if this ever breaks, the version too old packet will show up what version we
	// are supposed to have, then we simply reconnect using that version..
	// note: that code doesn't actually exist, so.. if it ever breaks that still needs to be written
	[self sendPacket:[XFPacket clientVersionPacket:9999999]];
}

#pragma mark - Sending and receiving data

- (void)sendData:(NSData *)data
{
	if( _status != XFConnectionConnected )
	{
		NSLog(@"*** Tried sending data of length %lu over disconnected XFConnection",[data length]);
		return;
	}
	[_socket sendData:data];
}

- (void)receivedData:(NSData *)data
{	
	if( !_session )
    {
        NSLog(@"Received data but no XFSession exists");
        return;
    }
	
	BOOL shouldContinue = YES;
	
	[_availableData appendData:data];
	while( shouldContinue && ([_availableData length] >= 5) )
	{
		const unsigned char *bytes = [_availableData bytes];
		unsigned short pktlen = (
                                 (((unsigned short)(bytes[1])) << 8) |
                                 ((unsigned short)(bytes[0]))
                                 );
		if( [_availableData length] >= pktlen )
		{
            NSRange pktRange;
            pktRange.location = 0;
            pktRange.length = pktlen;
			NSData *packetData = [_availableData subdataWithRange:pktRange];
            [_availableData replaceBytesInRange:pktRange withBytes:NULL length:0];
			XFPacket *packet = [XFPacket decodedPacketByScanningBuffer:packetData];
			
			if( packet )
				shouldContinue = [self processPacket:packet];
			else
                NSLog(@"Unable to scan data: \n%@",packetData);
		}
		else if( [_availableData length] >= 5 )
		{
			// Wait for more data, can't make a packet with 5 bytes
			break;
		}
	}
}

- (void)sendPacket:(XFPacket *)packet
{
	if( _status != XFConnectionConnected )
	{
		NSLog(@"*** Tried sending packet %@ on a disconnected xfire connection",packet);
		return;
	}
	else if( packet )
	{
		[self sendData:packet.data];
	}
}

#pragma mark - Keep alive

- (void)sendKeepAliveRequest
{
	[_keepAliveResponseTimer invalidate];
	_keepAliveResponseTimer = nil;
	_keepAliveResponseTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                               target:self
                                                             selector:@selector(keepAliveResponseTimeout:)
                                                             userInfo:nil
                                                              repeats:NO];
	
	// I don't know what they want in the statistics parameter..
	// it still works when its empty thuogh, so this is fine.
	NSArray *stats = [[NSArray alloc] init];
	[self sendPacket:[XFPacket keepAlivePacketWithValue:0 stats:stats]];
	[stats release];
}

- (void)keepAliveResponseTimeout:(NSTimer *)aTimer
{
    if( _keepAliveResponseTimer )
    {
        _keepAliveResponseTimer = nil;
		
		// this will also disconnect the connection therefore we are not doing it manually
		// in this method
		[_session connection:self willDisconnect:XFConnectionErrorStoppedResponding];
    }
}

#pragma mark - Processing packets

- (BOOL)processPacket:(XFPacket *)packet
{
	switch(packet.packetID)
	{
		case XFLoginRequestPacketID:
			[self processLoginPacket:packet];
			break;
            
		case XFLoginFailurePacketID:
			[_session loginFailed:XFLoginErrorInvalidPassword];
			return NO;
			break;
            
		case XFLoginSuccessPacketID:
			[self processLoginSuccessPacket:packet];
			break;
            
		case XFFriendsListPacketID:
			[self processFriendsListPacket:packet];
			break;
            
		case XFSessionIDPacketID:
			[self processSessionIDPacket:packet];
			break;
            
		case XFChatPacketID:
			[self processChatMessagePacket:packet];
			break;
            
		case XFVersionTooOldPacketID:
			[self processVersionTooOldPacket:packet];
			return NO;
			break;
            
		case XFGameStatusPacketID:
			[self processGameStatusPacket:packet];
			break;
            
		case XFFriendOfFriendPacketID:
			[self processFriendOfFriendPacket:packet];
			break;
            
        case XFInvitationResultPacketID:
            [self processInvitSend:packet];
            break;
            
		case XFFriendRequestPacketID:
			[self processFriendRequestPacket:packet];
			break;
            
		case XFRemoveFriendPacketID:
			[self processRemoveFriendPacket:packet];
			break;
            
		case XFPrefsPacketID:
			[self processUserOptionsPacket:packet];
			break;
            
		case XFSearchResultsPacketID:
			[self processSearchResultsPacket:packet];
			break;
            
		case XFKeepAliveResponsePacketID:
			[self processKeepAliveResponse:packet];
			break;
            
		case XFSignedOnFromOtherLocationPacketID:
			[self processDisconnectPacket:packet];
			return NO;
			break;
            
        case XFFriendVOIPSoftwarePacketID:
            /*
			 TODO: Implement this, a lot of users have been crying for this
			 
			 
             BlackFire[4402:903] packet:  ID 147, 4 attrs
             AttrMap {
             sid = [[ Packet Attribute, type = 4, arrType = 3, value = (
             "[[ Packet Attribute, type = 3, arrType = -1, value = <0d170985 78ac5881 f8d17774 fd3cd80a> ]]"
             ) ]]
             vid = [[ Packet Attribute, type = 4, arrType = 2, value = (
             "[[ Packet Attribute, type = 2, arrType = -1, value = 35 ]]"
             ) ]]
             vip = [[ Packet Attribute, type = 4, arrType = 2, value = (
             "[[ Packet Attribute, type = 2, arrType = -1, value = 1317126658 ]]"
             ) ]]
             vport = [[ Packet Attribute, type = 4, arrType = 2, value = (
             "[[ Packet Attribute, type = 2, arrType = -1, value = 9065 ]]"
             ) ]]
             }
             */
            break;
            
            
        case XFFavoriteServerListPacketID:
            [self processServerList:packet];
            break;
            
        case XFFriendsFavoriteServerListPacketID:
            break;
            
		case XFGroupsPacketID:
			[self processFriendGroupNamePacket:packet];
			break;
            
		case XFGroupMembersPacketID:
			[self processFriendGroupMemberPacket:packet];
			break;
            
		case XFAddGroupConfirmationPacketID:
			[self processFriendGroupNamePacket:packet];
			break;
            
		case XFFriendStatusPacketID:
			[self processFriendStatusPacket:packet];
			break;
            
        case XFGroupChatsPacketID:
            break;
            
        case XFGameClientDataPacketID:
            break;
            
        case XFScreenshotInfoPacketID:
            break;
            
            
        case XFClanGroupsPacketID:
            [self processClanListPacket:packet];
            break;
            
        case XFClanGroupMembersPacketID:
            [self processClanMembersPacket:packet];
            break;
            
		case XFNickNameChangePacketID:
			[self processNicknameChangePacket:packet];
			break;
            
        case XFClanGroupMemberNickNameChangePacketID:
            break;
            
		case XFClanGroupOrderPacketID:
			[self processFriendGroupListPacket:packet];
			break;
            
        case XFClanInvitePacketID:
            break;
            
        case XFSystemBroadcastPacketID:
            [self processSystemBroadcast:packet];
            break;
            
        case XFClanEventsPacketID:
            break;
            
        case XFClanEventDeletedPacketID:
            break;
            
        case XFFriendsScreenshotsInfoPacketID:
			break;
            
        case XFFriendsExtendedInfoPacketID:
            [self processFriendChangePacket:packet];  
            break;
			
		case XFAvatarInfoPacketID:
			[self processFriendAvatarPacket:packet];
			break;
            
        case XFWrongCentralServerIPAddressPacketID:
            NSLog(@"Wrong central server IP address: %@",packet);
            break;
            
        case XFClanGroupMemberInfoPacketID:
            break;
            
        case XFClanGroupNewsPacketID:
            break;
            
        case XFVideoInfoPacketID:
            break;
			
		case XFFriendsVideoInfoPacketID:
			break;
            
        case XFExternalGameInfoPacketID:
            break;
            
        case XFFriendBroadcastInfoPacketID:
			[self processBroadCastPacket:packet];
            break;
            
        case XFSocialNetworkListPacketID:
            break;
            
        case XFClanServerListPacketID:
            break;
            
        case XFContestInfoPacketID:
            break;
            
        case XFGroupChatRoomNameChangedPacketID:
            [self processChatRoomNameChanged:packet];
            break;
            
        case XFGroupChatJoinInfoPacketID:
            [self processChatRoomJoinInfo:packet];
            break;
            
        case XFGroupChatUserJoinedPacketID:
            [self processMemberJoined:packet];
            break;
            
        case XFGroupChatUserLeftPacketID:
            [self processMemberLeft:packet];
            break;
            
        case XFGroupChatMessagePacketID:
            [self processChatRoomMessage:packet];
            break;
            
        case XFGroupChatInvitePacketID:
            [self processChatRoomInvite:packet];
            break;
            
        case XFGroupChatUserRankChangedPacketID:
            [self processChatRoomUserLevelChanged:packet];
            break;
            
        case XFGroupChatPersistentInfoPacketID:
            break;
            
        case XFGroupChatUserKickedPacketID:
            [self processChatRoomUserGotKickedPacket:packet];
            break;
            
        case XFGroupChatDomainChangedPacketID:
            [self processChatRoomAccessChangedPacket:packet];
            break;
            
        case XFGroupChatMessageOfTheDayChangedPacketID:
            [self processChatRoomMotdChanged:packet];
            break;
            
        case XFGroupChatVoiceChatStatusChangedPacketID:
            break;
            
        case XFGroupChatInfoPacketID:
            [self processChatRoomMembers:packet];
            break;
            
        case XFGroupChatPasswordChangedPacketID:
            [self processChatRoomPasswordChangedPacket:packet];
            break;
            
        case XFGroupChatRejectConfirmationPacketID:
            break;
            
        case XFDownloadIdentifierPacketID:
            break;
            
        case XFDownloadNewChannelPacketID:
            break;
			
		case 190:
			// no idea what these packets do, values are constantly empty
			break;
			
		case 186:
			// no idea what these packets do, values are constantly empty
			break;
            
            // dump the packet that we don't know
		default:
            NSLog(@"Unknown packet: %@",packet);
			break;
	}
	return YES;
}








- (void)requestFriendInfo:(unsigned int)userID
{
	XFPacket *packet = [XFPacket friendInfoPacket:userID];
	[self sendPacket:packet];
}

- (void)processFriendAvatarPacket:(XFPacket *)pkt
{
	// TODO: Implement this
	/*[_session gotAvatarInfo:[(NSNumber *)[[pkt attributeForKey:@"0x01"] value] unsignedIntValue] 
                  andUserID:[(NSNumber *)[[pkt attributeForKey:@"0x34"] value] unsignedIntValue] 
                       type:[(NSNumber *)[[pkt attributeForKey:@"0x1f"] value] unsignedIntValue]];*/
}

- (void)processSystemBroadcast:(XFPacket *)pkt
{
	// TODO: Implement this
    //[_session delegate_sessionGotSystemBroadcast:[[pkt attributeForKey:@"0x2E"] value]];
}

- (void)processLoginPacket:(XFPacket *)pkt
{	
	NSString *username = [_session.delegate username];
	NSString *password = [_session.delegate password];
    
    
	NSAssert(username,@"Error while logging in, no username was found",nil);
    NSAssert(password,@"Error while logging in, no password was found",nil);
	
	// copy so we have a full identification on us
	[[_session loginIdentity] setUsername:username];
	
	NSString *salt = [[pkt attributeForKey:XFPacketSaltKey] value];
	
    NSString *cur = [[NSString alloc] initWithFormat:@"%@%@UltimateArena",username,password];
    NSData *hash = [[cur dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
    [cur release];
	
    cur = [[NSString alloc] initWithFormat:@"%@%@",[hash stringRepresentation], salt];
    hash = [[cur dataUsingEncoding:NSUTF8StringEncoding] sha1Hash];
    [cur release];
	
	XFPacket *loginPkt = [XFPacket loginPacketWithUsername:username
                                                  password:[hash stringRepresentation]
                                                     flags:0];
    
	[self sendPacket:loginPkt];
}

/*
 Extract information from the login success packet
 Set status to connected
 Send client info packet (skin, lang)
 Send network info packet
 
 SCR 37 - Don't set status to Online here, wait until we get the friends list (we've logged in more)
 */
- (void)processLoginSuccessPacket:(XFPacket *)pkt
{
	// Extract information from the login success packet
	// Contains useful information:
	//    unsigned int      user ID (userid)
	//    str               nickname (nick)
	//    uuid              session id (sid)
	//    int               public IP (pip)
	// Ignore: status, dlset, p2pset, clntset, minrect, maxrect, ctry, n1, n2, n3
	XFFriend *user = [_session loginIdentity];
	
	user.userID		= [(NSNumber *)[[pkt attributeForKey:XFPacketUserIDKey] value] unsignedIntValue];
	user.nickname	= [[pkt attributeForKey:XFPacketNickNameKey] value];
	user.sessionID	= (NSData *)[[pkt attributeForKey:XFPacketSessionIDKey] value];
	
	// TODO: fix the language attribute
	XFPacket *newPkt = [XFPacket clientInfoPacketWithLanguage:@"en"
                                                         skin:@"BlackFire2.0"
                                                        theme:@"aqua"
                                                      partner:@"Antwan van Houdt"];
	[self sendPacket:newPkt];
}

- (void)sendNetworkInfoPacketWithIP:(unsigned int)ip andNATType:(unsigned int)natType
{
	int natErr = 0;
	if( natType == 0 )
		natErr = 1;
	
    XFPacket *newPkt = [XFPacket networkInfoPacketWithConn:2 nat:natType sec:NO ip:ip naterr:natErr uPnPInfo:@""];
    [self sendPacket:newPkt];
}

// Get newest version
// We can't download the file
// Contains information:
//   int[]    Version numbers   (version)
//   str[]    File URLs         (file)
//   int[]    Command           (command) always 1?
//   int[]    File ID           (fileid)
//   int      Login flags       (flags)  always 0?
- (void)processVersionTooOldPacket:(XFPacket *)pkt
{
    NSLog(@"Version too old: %@",pkt);
	NSArray  *versions = (NSArray *)[[pkt attributeForKey:XFPacketVersionKey] value];
	if( [versions isKindOfClass:[NSArray class]] && ([versions count] > 0) )
	{
		// For now, just get the first number
        //[self setClientVersion:[(NSNumber *)[[versions objectAtIndex:0] value] unsignedIntValue]];
		//[_session setLatestClientVersion:[(NSNumber *)[[versions objectAtIndex:0] value] unsignedIntValue]];
	}
	[_session loginFailed:XFLoginErrorVersionTooOld];
}

// Read the list of friends and add it
// Contains information:
//   str[]    User Names   (friends)
//   str[]    Nick names   (nick)
//   int[]    User IDs     (userid)
- (void)processFriendsListPacket:(XFPacket *)pkt
{
	
	if( !_session ) { [self disconnect]; return; }
	
	// SCR 37 - This prevents the main app from sending packets before we have a friends list
	// Careful because this will not wait for status change, but friend list changes will wait
	// I think it all gets queued through the NSRunLoop of the main thread, so we should be okay
	NSArray *usernames, *nicknames, *userids;
	usernames = [pkt attributeValuesForKey:XFPacketFriendsKey];
	nicknames = [pkt attributeValuesForKey:XFPacketNickNameKey];
	userids   = [pkt attributeValuesForKey:XFPacketUserIDKey];
	
	NSUInteger i,cnt = [usernames count];
	if( cnt != [nicknames count] || cnt != [userids count] )
    {
        NSLog(@"Received an invalid friends list packet, someone is sending malicious data to blackfire");
		return;
    }
	
	XFGroup *offlineGroup = [_session.groupController offlineFriendsGroup];
	for( i = 0; i < cnt; i++ )
	{
		unsigned int uID = [[userids objectAtIndex:i] unsignedIntValue];
		XFFriend *friend = [_session friendForUserID:uID];
		
		if( ! friend )
		{
			friend = [[XFFriend alloc] initWithSession:_session];
			friend.username = [usernames objectAtIndex:i];
			friend.userID	= uID;
			friend.nickname = [nicknames objectAtIndex:i];
			
			[offlineGroup addMember:friend];
			
			[_session addFriend:friend];
			
			[friend release];
		}
	}
	
	// the most ugly part of the Xfire protocol.
	// I see this as an extremely big mistake they made.
	// We never know when we are actually online, we uset his packet to assume we are online
	// in 3 seconds, the GUI also hsa to know about this.
	// the problem is that we will keep receiving sessionIDS for about 3 seconds, yeah this can go wrong
	// on slow connections but we have nothing to fix this with. Believe me, I tried.
	// I have reported this to the xfire development team and we will see if they ever change the protocol
	if( _session.status != XFSessionStatusOnline )
		[_session setStatus:XFSessionStatusOnline];
	
}

// Contains a list of userids and session IDs
// Tells us who is online and offline
// Contains information:
//   int[]   User IDs  (userid)
//   uuid[]  Session IDs (sid)
- (void)processSessionIDPacket:(XFPacket *)pkt
{
	NSArray *userids    = [pkt attributeValuesForKey:@"0x01"];
	NSArray *sessionids = [pkt attributeValuesForKey:@"0x03"];
	
	NSUInteger i, cnt = [userids count];
	if( cnt != [sessionids count] ) 
	{
		NSLog(@"*** Received invalid session ID packet");
		return;
	}
	
	XFGroup *offlineGroup	= [_session.groupController offlineFriendsGroup];
	XFGroup *onlineGroup	= [_session.groupController onlineFriendsGroup];
	for(i=0;i<cnt;i++)
	{
		unsigned int uid = [[userids objectAtIndex:i] unsignedIntValue];
		NSData *sid = [sessionids objectAtIndex:i];
		
		XFFriend *friend = [_session friendForUserID:uid];
		
		if( [sid isClear] )
		{
			[onlineGroup removeMember:friend];
			[offlineGroup addMember:friend];
			[friend clearInformation];
			friend.online = false;
			friend.sessionID = sid;
		}
		else
		{
			[offlineGroup removeMember:friend];
			[onlineGroup addMember:friend];
			friend.online = true;
			friend.sessionID = sid;
		}
	}
	[offlineGroup sortMembers];
	[onlineGroup sortMembers];
}

// Contains a list of status strings for a given user's session
// Contains information:
//   uuid[]  Session IDs (sid)
//   str[]   Message String (msg)
- (void)processFriendStatusPacket:(XFPacket *)pkt
{	
	NSArray *sessionids  = [pkt attributeValuesForKey:XFPacketSessionIDKey];
	NSArray *msgs        = [pkt attributeValuesForKey:XFPacketMessageKey];
    
    NSUInteger i, cnt = [sessionids count];
	
	if( cnt != [msgs count] )
	{
		NSLog(@"*** Received invalid friend status packet");
		return;
	}

	for(i=0;i<cnt;i++)
	{
		XFFriend *friend = [_session friendForSessionID:[sessionids objectAtIndex:i]];
		friend.status = [msgs objectAtIndex:i];
	}
}

// Contains game ID, IP, and port information for a given user
// This represents status-changed message
// Contains information:
//   uuid[]  Session IDs  (sid)
//   int[]   Game ID      (gameid)
//   int[]   Game IP addr (gip)
//   int[]   Game Port    (gport)
// Anyone that is not on our friends list, we will request FoF information if allowed
- (void)processGameStatusPacket:(XFPacket *)pkt
{
	NSMutableArray *unknownSids = [[NSMutableArray alloc] init];
	
	NSArray *sessionIDs  = [pkt attributeValuesForKey:XFPacketSessionIDKey];
	NSArray *gameIDs     = [pkt attributeValuesForKey:XFPacketGameIDKey];
	NSArray *gameIPAddrs = [pkt attributeValuesForKey:XFPacketGameIPKey];
	NSArray *gamePorts   = [pkt attributeValuesForKey:XFPacketGamePortKey];
	
	NSUInteger i, cnt = [sessionIDs count];
	for( i = 0; i < cnt; i++ )
	{
		NSData *sid         = [sessionIDs objectAtIndex:i];
		unsigned int gid    = [[gameIDs objectAtIndex:i] unsignedIntValue];
		
		XFFriend *friend = [_session friendForSessionID:sid];
		if( ! friend )
		{
			[unknownSids addObject:sid];
		}
		else
		{
			friend.gameID	= gid;
			friend.gameIP	= [[gameIPAddrs objectAtIndex:i] unsignedIntValue];
			friend.gamePort = [[gamePorts objectAtIndex:i] unsignedIntValue];
		}
	}
	
	// Some Session IDs were unknown.  These correspond to Friends of Friends
	// Request that information if the user requests it
	if( ([unknownSids count] > 0) && [_session shouldShowFriendsOfFriends] )
	{
		XFPacket *packet = [XFPacket friendOfFriendRequestPacketWithSIDs:unknownSids];
		[self sendPacket:packet];
	}
	[unknownSids release]; // don't leak
}

// Contains information about our friends-of-friends
// Contains information:
//   uuid[]  Session IDs    (fnsid)
//   int[]   User IDs       (userid)
//   str[]   User Names     (name)
//   str[]   Nick names     (nick)
//   int[][] Mutual Friends (friends)
// Ignore mutual friends for now
- (void)processFriendOfFriendPacket:(XFPacket *)pkt
{
	NSArray *sessionIDs, *userIDs, *userNames, *nickNames, *commonFriends, *common;
	NSString *username, *nickname;
	
	sessionIDs		= [pkt attributeValuesForKey:XFPacketFriendSIDKey];
	userIDs			= [pkt attributeValuesForKey:XFPacketUserIDKey];
	userNames		= [pkt attributeValuesForKey:XFPacketNameKey];
	nickNames		= [pkt attributeValuesForKey:XFPacketNickNameKey];
	commonFriends	= [pkt attributeValuesForKey:XFPacketFriendsKey];
	
	XFGroup *fofGroup = [_session.groupController friendsOfFriendsGroup];
	NSUInteger i, cnt = [sessionIDs count];
	for( i = 0; i < cnt; i++ )
	{
		NSData *sid = [sessionIDs objectAtIndex:i];
		username = [userNames objectAtIndex:i];
		nickname = [nickNames objectAtIndex:i];
		common = [commonFriends objectAtIndex:i]; // it's an array of XFPacketAttributeValue objects containing NSNumbers
		
		XFFriend *friend = [_session friendForSessionID:sid];
		if( friend )
		{
			break; // this means that we _know_ this friend and so its not a FoF
		}
		
		// Can be 0 if this person went offline, I think
		if( [username length] > 0 )
		{
			XFFriend *friend = [[XFFriend alloc] init];
			friend.userID			= [[userIDs objectAtIndex:i] unsignedIntValue];
			friend.username			= username;
			friend.nickname			= nickname;
			friend.sessionID		= sid;
			friend.online			= true;
			friend.friendOfFriend	= true;
			
			[fofGroup addMember:friend];
			
			[_session addFriend:friend];
			
			[friend release];
		}
	}
	[fofGroup sortMembers];
}

- (void)processNicknameChangePacket:(XFPacket *)pkt
{
	NSArray *userIDs, *nickNames;
	
	userIDs   = [pkt attributeValuesForKey:@"0x01"];
	nickNames = [pkt attributeValuesForKey:@"0x0d"];
	
	NSUInteger i, cnt = [userIDs count];
	for( i = 0; i < cnt; i++ )
	{
		NSString *nickname = [nickNames objectAtIndex:i];
		unsigned int uid = [[userIDs objectAtIndex:i] unsignedIntValue];
		
		XFFriend *friend = [_session friendForUserID:uid];
		if( friend )
		{
			friend.nickname = nickname;
		}
	}
}

- (void)processSearchResultsPacket:(XFPacket *)pkt
{
	NSArray *userNames,*firstNames,*lastNames;
	
	NSMutableArray *friends = [NSMutableArray array];
	
	userNames = [pkt attributeValuesForKey:XFPacketNameKey];
	firstNames = [pkt attributeValuesForKey:XFPacketFirstNameKey];
	lastNames = [pkt attributeValuesForKey:XFPacketLastNameKey];
	
	NSUInteger i, cnt = [userNames count];
	for(i=0;i<cnt;i++)
	{
		XFFriend *friend = [[XFFriend alloc] init];
		
		friend.username		= [userNames objectAtIndex:i];
		friend.firstName	= [firstNames objectAtIndex:i];
		friend.lastName		= [lastNames objectAtIndex:i];
		
		[friends addObject:friend];
		[friend release];
	}
	
	// TODO: Process search results
	
/*	unsigned int i, cnt = [userNames count];
	for( i = 0; i < cnt; i++ )
	{
		fr = [[XFFriend alloc] init];
		
		[fr setUserName:[userNames objectAtIndex:i]];
		[fr setFirstName:[firstNames objectAtIndex:i]];
		[fr setLastName:[lastNames objectAtIndex:i]];
		
		[friends addObject:fr];
		[fr release];
	}
	
	[_session delegate_searchResults:friends];*/
}

- (void)processRemoveFriendPacket:(XFPacket *)pkt
{
	NSArray *userIDs = [pkt attributeValuesForKey:XFPacketUserIDKey];
	
	NSUInteger i, cnt = [userIDs count];
	for(i=0;i<cnt;i++)
	{
		[_session friendWasDeleted:[[userIDs objectAtIndex:i] unsignedIntValue]];
	}
}

- (void)processFriendRequestPacket:(XFPacket *)pkt
{	
	NSMutableArray *friends = [[NSMutableArray alloc] init];
	//XFFriend *fr;
	
	NSArray *userNames = [pkt attributeValuesForKey:XFPacketNameKey];
	NSArray *nickNames = [pkt attributeValuesForKey:XFPacketNickNameKey];
	NSArray *messages  = [pkt attributeValuesForKey:XFPacketMessageKey];
	
	NSUInteger i, cnt = [userNames count];
	for(i=0;i<cnt;i++)
	{
		XFFriend *friend = [[XFFriend alloc] init];
		
		friend.username = [userNames objectAtIndex:i];
		friend.nickname = [nickNames objectAtIndex:i];
		friend.status	= [messages objectAtIndex:i];
		
		[friends addObject:friend];
		[friend release];
	}
    
/*	unsigned int i, cnt = [userNames count];
	for( i = 0; i < cnt; i++ )
	{
		fr = [[XFFriend alloc] init];
        
		[fr setUserName:[userNames objectAtIndex:i]];
        if( i < [nickNames count] )
            [fr setNickName:[nickNames objectAtIndex:i]];
        if( i < [messages count] )
            [fr setStatusString:[messages objectAtIndex:i]];
        if( ![fr isBlocked] )
            [friends addObject:fr];
		[fr release];
	}
	[_session delegate_didReceiveFriendshipRequests:friends];
    [friends release];*/
}

- (void)processFriendGroupNamePacket:(XFPacket *)pkt
{
	NSArray *groupIDs,*groupNames;
	XFGroupController *ctl = _session.groupController;
	NSString *groupName;
	
	groupIDs   = [pkt attributeValuesForKey:@"0x19"];
	groupNames = [pkt attributeValuesForKey:@"0x1a"];
	
	NSUInteger i, cnt = [groupIDs count];
	for( i = 0; i < cnt; i++ )
	{
		groupName = [groupNames objectAtIndex:i];
		[ctl addCustomGroup:groupName groupID:[[groupIDs objectAtIndex:i] intValue]];
	}
}

- (void)processFriendGroupMemberPacket:(XFPacket *)pkt
{
	NSArray *userIDs;
	NSArray *groupIDs;
	XFGroupController *ctl = [_session groupController];
	
	userIDs    = [pkt attributeValuesForKey:@"0x01"];
	groupIDs   = [pkt attributeValuesForKey:@"0x19"];
	
	NSUInteger i, cnt = [userIDs count];
	for( i = 0; i < cnt; i++ )
	{
		XFFriend *friend = [_session friendForUserID:[[userIDs objectAtIndex:i] unsignedIntValue]];
		if( friend )
		{
			XFGroup *group = [ctl groupForID:[[groupIDs objectAtIndex:i] unsignedIntValue]];
			if( group )
			{
				[group addMember:friend];
				[group sortMembers];
			}
		}
	}
}

/*
 This packet (ID 163) contains 3 keys with integer array values.
 Key 0x19 is the group ID.
 Key 0x34 appears to be a type (best guess).  0 = custom, 2 = dynamic
 Key 0x12 is unknown.
 
 Keys 0x34 and 0x12 are ignored for now.
 
 It is not known what the purpose of the values are in this packet, as it can be empty.
 */
- (void)processFriendGroupListPacket:(XFPacket *)pkt
{
#if 0
	//[[[self session] friendGroupController] setGroupList:[pkt attributeValuesForKey:@"0x19"]];
#endif
}

- (void)processUserOptionsPacket:(XFPacket *)pkt
{
	NSArray *maps = [pkt attributeValuesForKey:@"0x4c"];
	if( [maps count] != 1 )
		return;
	
	XFPacketDictionary *map = [maps objectAtIndex:0];
	if( !map || ![map isKindOfClass:[XFPacketDictionary class]])
	{
		NSLog(@"Got something unexpected: %@",map);
		return;
	}
	
	// As far as I know, we only get this at login and possibly when explicitly setting
	// options, so not triggering notifications should be ok in all cases.
	//[_session _privateSetUserOptions:prefs];
    //[prefs release];
    
    XFPacketAttributeValue *attr = nil;
    
    NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
    
    attr = [map objectForKey:@"0x01"];
    if( attr )
        [std setBool:[[attr value] boolValue] forKey:@"showOthersGameStatus"];
    attr = [map objectForKey:@"0x02"];
    if( attr )
        [std setBool:[[attr value] boolValue] forKey:@"xfireShowGameServerData"];
    attr = [map objectForKey:@"0x03"];
    if( attr )
        [std setBool:[[attr value] boolValue] forKey:@"xfireStatusOnProfile"];
    //  [std setBool:[[[map objectForKey:@"0x04"] value] boolValue] forKey:@"playReceiveOrSendSound"];
    //  [std setBool:[[[map objectForKey:@"0x05"] value] boolValue] forKey:@"playReceiveIngameSound"];
    attr = [map objectForKey:@"0x06"];
    if( attr )
        [std setBool:[[attr value] boolValue] forKey:@"enableTimeStamps"];
    
    attr = [map objectForKey:@"0x08"];
    if( attr )
        [std setBool:[[attr value] boolValue] forKey:@"showFriendsOfFriendsGroup"];
    
    attr = [map objectForKey:@"0x09"];
    if( attr )
        [std setBool:[[attr value] boolValue] forKey:@"showOfflineFriendsGroup"];
    
    attr = [map objectForKey:@"0x0a"];
    if( attr )
        [std setBool:([[attr value] boolValue]) forKey:@"forceUsername"];
    
    attr = [map objectForKey:@"0x0c"];
    if( attr )
        [std setBool:([[attr value] boolValue]) forKey:@"showOthersWhenTyping"];
    
    //  [std setBool:[[[map objectForKey:@"0x10"] value] boolValue] forKey:@"enableGrowlFriendOnlineOffline"];
    //  [std setBool:[[[map objectForKey:@"0x11"] value] boolValue] forKey:@"enableGrowlWhenDownloadFinishes"];
    
	
	// Now that we know the user's preferences, enable the customizable groups
	/*[[_session friendGroupController] ensureStandardGroup:XFFriendGroupOnline];
	if( [_session shouldShowFriendsOfFriends] )
		[[_session friendGroupController] ensureStandardGroup:XFFriendGroupFriendOfFriends];
	if( [_session shouldShowOfflineFriends] )
		[[_session friendGroupController] ensureStandardGroup:XFFriendGroupOffline];
	 */
	// TODO: implement groups like this
}

- (void)processChatMessagePacket:(XFPacket *)pkt
{
	// check for the chat, otherwise create it
	NSData *sessionID = (NSData *)[[pkt attributeForKey:XFPacketSessionIDKey] value];
	XFChat *chat = [_session chatForSessionID:sessionID];
	if( !chat )
	{
		XFFriend *friend = [_session friendForSessionID:sessionID];
		if( friend )
			chat = [_session beginNewChatForFriend:friend];
		else
		{
			NSLog(@"*** Received a chat request for an unknown friend");
			return;
		}
	}
	
	// decode the packet and notify the XFChat object
	XFPacketDictionary *peermsg = (XFPacketDictionary *)[[pkt attributeForKey:XFPacketPeerMessageKey] value];
	switch( [[[peermsg objectForKey:XFPacketMessageTypeKey] value] intValue] )
	{
		case 0: // chat message
		{
			unsigned long imIndex = [[[peermsg objectForKey:XFPacketIMIndexKey] value] longLongValue];
			NSString *message = [[peermsg objectForKey:XFPacketIMKey] value];
			[chat receivedMessage:message];
			XFPacket *sendPkt = [XFPacket chatAcknowledgementPacketWithSID:[chat.remoteFriend sessionID] 
																   imIndex:(unsigned int)imIndex];
			[self sendPacket:sendPkt];
		}
			break;
			
		case 1: // acknowledgement
		{
			NSUInteger idx = [[[peermsg objectForKey:XFPacketIMIndexKey] value] intValue];
			
		}
			break;
			
		case 2: 
		{
			// for PTP connections
		}
			break;
			
		case 3: // typing notification
			[chat receivedIsTypingNotification];
			break;
	}
}

- (void)processDisconnectPacket:(XFPacket *)pkt
{
    if( [[[pkt attributeForKey:XFPacketReasonKey] value] intValue] == 1 )
    {
		[_session connection:self willDisconnect:XFConnectionErrorOtherSession];
    }
    else
    {
		[_session connection:self willDisconnect:XFConnectionErrorHungUp];
    }
}

- (void)processKeepAliveResponse:(XFPacket *)pkt
{
    if( _keepAliveResponseTimer )
    {
        [_keepAliveResponseTimer invalidate];
        _keepAliveResponseTimer = nil;
    }
}

#pragma mark ClanList packet handling

- (void)processClanListPacket:(XFPacket *)pkt
{
    NSArray             *groupIDs       = [pkt attributeValuesForKey:@"0x6c"];
    NSArray             *clanList       = [pkt attributeValuesForKey:@"0x02"];
    XFGroupController   *ctr            = [_session groupController];
    
	NSUInteger i, cnt = [clanList count];
    for( i = 0; i < cnt;i++ ) 
    {
		[ctr addClanGroup:[clanList objectAtIndex:i] groupID:[[groupIDs objectAtIndex:i] intValue]];
    }
}

- (void)processClanMembersPacket:(XFPacket *)pkt
{
	XFGroupController *ctl = [_session groupController];
	NSArray *userIDs, *userNames, *nickNames, *clanNicks, *groupIDs;
	
	XFFriend *me = [_session loginIdentity];
	
	// arrays of member info
	userIDs   = [pkt attributeValuesForKey:@"0x01"];
	userNames = [pkt attributeValuesForKey:@"0x02"];
	nickNames = [pkt attributeValuesForKey:@"0x0d"];
	clanNicks = [pkt attributeValuesForKey:@"0x6d"];
	groupIDs  = [pkt attributeValuesForKey:@"0x6c"];
	
	NSUInteger i, cnt = [userIDs count];
	XFGroup *clanGrp = [ctl groupForID:[[groupIDs objectAtIndex:0] intValue]];
	for( i = 0; i < cnt;i++ )
	{
		unsigned int userID		= [[userIDs objectAtIndex:i] unsignedIntValue];
		NSString *username		= [userNames objectAtIndex:i];
		NSString *nickname		= [nickNames objectAtIndex:i];
		//NSString *clanNickname	= [clanNicks objectAtIndex:i];
		
		
		if( [username length] > 0 && userID != me.userID )
		{
			XFFriend *fr = [_session friendForUserID:userID];
			if( !fr )
			{
				fr = [[XFFriend alloc] init];
				fr.userID = userID;
				fr.username = username;
				fr.nickname = nickname;
				fr.clanFriend = true;
				
				[_session addFriend:fr];
				[clanGrp addMember:fr];
				[fr release];
				
				// TODO: Add support for clan nicknames
			}
			else
			{
				[clanGrp addMember:fr];
			}
		} 
	}
    //[_session delegate_friendGroupDidChange:clanGrp];
	[clanGrp sortMembers];
}

- (void)processFriendChangePacket:(XFPacket *)pkt
{
	// seriously, a packet  with 1 attribute? WHAT THE F*CK, ok ok, lets find out what it actually does by dumping it
	// as soon as we receive it..
	NSLog(@"Useless packet received: %@",pkt);
   /* unsigned int userID = [[[pkt attributeValuesForKey:@"0x01"] objectAtIndex:0] unsignedIntValue];
    XFFriend *friend = [_session friendForUserID:userID];
    if( friend )
        [_session delegate_friendDidChange:friend attribute:XFFriendStatusStringDidChange];
	*/
}



#pragma mark - Server list

- (void)processServerList:(XFPacket *)pkt
{
    NSArray *gamesArray = [pkt attributeValuesForKey:XFPacketGameIDKey];
    NSArray *gameIPs    = [pkt attributeValuesForKey:XFPacketGameIPKey];
    NSArray *gamePorts  = [pkt attributeValuesForKey:XFPacketGamePortKey];
	
    NSMutableArray *serverList = [[NSMutableArray alloc] init];
    
    NSUInteger i, addr, cnt = [gameIPs count];
    for(i=0;i<cnt;i++)
    {
        addr = [[gameIPs objectAtIndex:i] unsignedIntValue];
		
		XFGameServer *server = [[XFGameServer alloc] init];
		server.IPAddress	= [[gameIPs objectAtIndex:i] unsignedIntValue];
		server.Port			= [[gamePorts objectAtIndex:i] unsignedIntValue];
		server.gameID		= [[gamesArray objectAtIndex:i] unsignedIntValue];
        [serverList addObject:server];
		
		[server release];
    }
   // [_session setServerList:serverList];
    [serverList release];
}

- (void)processInvitSend:(XFPacket *)pkt
{
    NSString *name    = [[pkt attributeValuesForKey:@"name"] objectAtIndex:0];
    NSString *message = [NSString stringWithFormat:@"Friend request invitation has been sent to %@, he/she will be added to your friends list as soon as he/she accepts",name];
    NSRunAlertPanel(@"Invitation has been sent", message, @"OK", nil, nil);
}

#pragma mark - Broadcasting

- (void)processBroadCastPacket:(XFPacket *)pkt
{
	// this packet can be used inside on XfireChat to notify the user that
	// the friend started broadcasting
	/*if( pkt )
	{
		NSData *sid = [[pkt attributeValuesForKey:@"0x03"] objectAtIndex:0];
		if( [sid length] == 16 )
		{
			XFChat *chat = [_session chatForSessionID:sid];
			if( chat )
			{
				[chat receivedBroadcast];
			}
			else
			{
				NSLog(@"No chat was found for the session ID of this broadcast");
			}
		}
		else
		{
			NSLog(@"Received a broadcastt pacekt with an invalid session ID");
		}
	}*/
}

#pragma mark - Chat rooms

/*- (void) processChatRoomMotdChanged:(XFPacket *)pkt
{
    NSData *sid = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        NSString *messageOfTheDay = [[pkt attributeValuesForKey:@"0x2e"] objectAtIndex:0];
        if( messageOfTheDay )
        {
            [grpChat setMotd:messageOfTheDay];
        }
    }
}

- (void) processChatRoomNameChanged:(XFPacket *)pkt
{
    NSData *sid = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        NSString *roomName = [[pkt attributeValuesForKey:@"0x05"] objectAtIndex:0];
        if( roomName )
            [grpChat setChatRoomName:roomName];
    }
}

- (void) processChatRoomUserLevelChanged:(XFPacket *)pkt
{
    NSData *sid = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    unsigned int userID = [[[pkt attributeValuesForKey:@"0x18"] objectAtIndex:0] unsignedIntValue];
    XFFriend *user = [_session friendForUserID:userID];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        int yourpermission = [[[pkt attributeValuesForKey:@"0x13"] objectAtIndex:0] intValue];
        if( userID == [[_session loginIdentity] userID] )
        {
            [grpChat setUserLevel:yourpermission];
        }
		[grpChat setPermissionForUserName:[user userName] withLevel:[NSNumber numberWithInt:yourpermission]];
    }
}

- (void) processChatRoomUserGotKickedPacket:(XFPacket *)pkt
{
    NSData *sid = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        unsigned int userID = [[[pkt attributeValuesForKey:@"0x18"] objectAtIndex:0] unsignedIntValue];
        if( userID != 0 )
        {
            if( userID == [[_session loginIdentity] userID] )
            {
                // TODO: Better implementation:?
				// NSRunAlertPanel(@"Kicked!", @"You got kicked from the chatroom", @"OK", nil, nil);
                //[_session groupChatDidEnd:sid kicked:YES];
                //[grpChat close];
				[grpChat kicked];
            }
            else
                [grpChat kickedUser:userID];
        }
    }
}

- (void)processChatRoomInvite:(XFPacket *)pkt
{
    NSData *sid         = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    NSString *nickName  = [[pkt attributeValuesForKey:@"0x0d"] objectAtIndex:0];
    NSString *message   = [[pkt attributeValuesForKey:@"0x05"] objectAtIndex:0];
    NSString *errorMessage = [NSString 
                              stringWithFormat:@"%@ invited you to chatroom %@",
                              nickName,message];
    
    int result = NSRunAlertPanel(@"Chatroom invite", errorMessage, @"Accept", @"Decline", nil);
    if( result == NSOKButton )
    {
        XFPacket *sendPkt = [XFPacket joinChatRoomPacket:sid withName:message andPassword:@""];
        [self sendPacket:sendPkt];
    } 
    else
    {
        XFPacket *sendPkt = [XFPacket denyRoomInvitationPacket:sid];
        [self sendPacket:sendPkt];
    }
}

- (void)processChatRoomJoinInfo:(XFPacket *)pkt
{
    NSData      *sid               = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    int         yourpermission     = [[[pkt attributeValuesForKey:@"0x12"] objectAtIndex:0] intValue];
    NSString    *roomName          = [[pkt attributeValuesForKey:@"0x05"] objectAtIndex:0];
    NSString    *messageOfTheDay   = [[pkt attributeValuesForKey:@"0x4d"] objectAtIndex:0];
    
    
    [_session groupChatDidStart:sid withName:roomName andMotd:messageOfTheDay];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        [grpChat setUserLevel:yourpermission];
    }
}

- (void)processChatRoomMessage:(XFPacket *)pkt
{
    NSData *sid         = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    NSString *message   = [[pkt attributeValuesForKey:@"0x2e"] objectAtIndex:0];
    unsigned int userID = [[[pkt attributeValuesForKey:@"0x01"] objectAtIndex:0] unsignedIntValue];
    
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat == nil || userID == 0 || message == nil )
    {
        NSLog(@"**Received a corrupt XFGroupChat message packet");
        return;
    }
    
    [grpChat receivedMessage:message from:userID];
}

- (void)processMemberJoined:(XFPacket *)pkt{
    NSData          *sid        = [[pkt attributeValuesForKey:@"0x04"]  objectAtIndex:0];
    NSString        *userName   = [[pkt attributeValuesForKey:@"0x02"]  objectAtIndex:0];
    NSString        *nickName   = [[pkt attributeValuesForKey:@"0x0d"]  objectAtIndex:0];
    unsigned int    userID      = [[[pkt attributeValuesForKey:@"0x01"] objectAtIndex:0] unsignedIntValue];
    
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat == nil )
    {
        NSLog(@"**Received memberjoined packet for unknown XFGroupChat");
        return;
    }
    
    XFFriend *friend = [[XFFriend alloc] init];
    [friend setUserName:userName];
    [friend setNickName:nickName];
    [friend setUserID:userID];
    [grpChat setPermissionForUserName:userName withLevel:[[pkt attributeValuesForKey:@"0x12"] objectAtIndex:0]];
    [grpChat addMember:friend];
    [friend release];
}

- (void)processMemberLeft:(XFPacket *)pkt
{
    NSData *sid         = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    unsigned int userID = [[[pkt attributeValuesForKey:@"0x01"] objectAtIndex:0] unsignedIntValue];
    
    if( [sid length] == 21 && userID != 0 )
    {
        XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
        if( grpChat )
        {
            [grpChat removeMember:userID];
        }
    }
    else
    {
        NSLog(@"**Received a corrupt chatroom-memberLeft packet");
    }
}

- (void)processChatRoomMembers:(XFPacket *)pkt
{
    NSArray *uIDs           = [pkt attributeValuesForKey:@"0x33"];
    NSArray *usernames      = [pkt attributeValuesForKey:@"0x42"];
    NSArray *nicks          = [pkt attributeValuesForKey:@"0x43"];
    NSArray *permissions    = [pkt attributeValuesForKey:@"0x44"];
    
    XFGroupChat *grp        = [_session groupChatForSessionID:[[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0]];
    if( ! grp )
    {
        NSLog(@"**Received chatroom members packet for unknown chatroom");
        return;
    }
    
    [grp setPublic:[(NSNumber *)[[pkt attributeValuesForKey:@"0x17"] objectAtIndex:0] boolValue]];
    unsigned int i, cnt = [usernames count];
    for(i=0;i<cnt;i++)
    {
        XFFriend *friend = [[XFFriend alloc] init];
        [friend setUserName:[usernames objectAtIndex:i]];
        [friend setNickName:[nicks objectAtIndex:i]];
        [friend setUserID:[[uIDs objectAtIndex:i] unsignedIntValue]];
        [grp addMember:friend];
        [grp setPermissionForUserName:[friend userName] withLevel:[permissions objectAtIndex:i]];
        [friend release];
    }
}

- (void) processChatRoomAccessChangedPacket:(XFPacket *)pkt
{
    NSData *sid = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        [grpChat setPublic:[(NSNumber *)[[pkt attributeValuesForKey:@"0x17"] objectAtIndex:0] boolValue]];
    }
}

- (void) processChatRoomPasswordChangedPacket:(XFPacket *)pkt
{
    NSData *sid = [[pkt attributeValuesForKey:@"0x04"] objectAtIndex:0];
    XFGroupChat *grpChat = [_session groupChatForSessionID:sid];
    if( grpChat )
    {
        [grpChat setPassword:[[pkt attributeValuesForKey:@"0x5f"] objectAtIndex:0]];
    }
}

- (void)createNewChatRoom:(NSString *)name andPassword:(NSString *)password{
    XFPacket *pkt = [XFPacket createNewChatRoom:name withPassword:password];
    if( pkt ) [self sendPacket:pkt];
}

- (void)processChatRoomsPacket:(XFPacket *)pkt
{
    //if( [_session status] != XFSessionStatusOnline )
    //  [_session setStatus:XFSessionStatusOnline];
}*/

#pragma mark - Sending Packets

@end
