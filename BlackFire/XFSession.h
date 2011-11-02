//
//  XFSession.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// login failure reasons
extern NSString *XFVersionTooOldReason;
extern NSString *XFInvalidPasswordReason;
extern NSString *XFNetworkErrorReason;

// Disconnect reasons
extern NSString *XFOtherSessionReason;
extern NSString *XFServerHungUpReason;
extern NSString *XFServerStoppedRespondingReason;
extern NSString *XFNormalDisconnectReason;

extern NSString *XFFriendDidChangeNotification;
extern NSString *XFFriendChangeAttribute;

typedef enum
{
	XFShowMyFriendsOption = 0,
	XFShowMyGameServerDataOption,
	XFShowOnMyProfileOption,
	XFShowChatTimeStampsOption,
	XFShowFriendsOfFriendsOption,
	XFShowMyOfflineFriendsOption,
	XFShowNicknamesOption,
	XFShowVoiceChatServerOption,
	XFShowWhenITypeOption
} XFPreferences;

typedef enum{
	XFSessionStatusOffline			= 0,
	XFSessionStatusConnecting		= 1,
	XFSessionStatusOnline			= 2,
	XFSessionStatusDisconnecting	= 3
} XFSessionStatus;

@class XFConnection, XFFriend, XFGroup;

@interface XFSession : NSObject
{
	XFConnection	*_tcpConnection;
	XFFriend		*_loginIdentity;
	
	XFSessionStatus _status;
}

@property (readonly) XFConnection *tcpConnection;
@property (nonatomic, assign) XFFriend *loginIdentity;

@property (readonly) XFSessionStatus status;

- (void)setStatus:(XFSessionStatus)newStatus;

@end
