//
//  XFSession.h
//  BlackFire
//
//  Created by Antwan van Houdt on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *XFFriendDidChangeNotification;
extern NSString *XFFriendChangeAttribute;

typedef enum
{
	XFLoginErrorVersionTooOld = 0,
	XFLoginErrorInvalidPassword,
	XFLoginErrorNetworkError
} XFLoginError;

typedef enum
{
	XFConnectionErrorOtherSession = 0,
	XFConnectionErrorHungUp,
	XFConnectionErrorStoppedResponding,
	XFConnectionErrorNormalDisconnect
} XFConnectionError;

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

typedef enum
{
	XFFriendNotificationOnlineStatusChanged = 0,
	XFFriendNotificationStatusChanged,
	XFFriendNotificationFriendAdded,
	XFFriendNotificationFriendRemoved
} XFFriendNotification;

typedef enum{
	XFSessionStatusOffline			= 0,
	XFSessionStatusConnecting		= 1,
	XFSessionStatusOnline			= 2,
	XFSessionStatusDisconnecting	= 3
} XFSessionStatus;

@class XFConnection, XFFriend, XFGroup, XFSession, XFGroupController;

@protocol XFSessionDelegate <NSObject>
- (void)session:(XFSession *)session loginFailed:(XFLoginError)reason;
- (void)session:(XFSession *)session statusChanged:(XFSessionStatus)newStatus;
@end

@interface XFSession : NSObject
{
	XFConnection		*_tcpConnection;
	XFFriend			*_loginIdentity;
	XFGroupController	*_groupController;
	
	id <XFSessionDelegate> _delegate;
	
	NSMutableArray	*_friends;
	NSTimer			*_keepAliveTimer;
	
	XFSessionStatus _status;
}

@property (readonly) XFConnection *tcpConnection;
@property (nonatomic, assign) XFFriend *loginIdentity;
@property (nonatomic, assign) id <XFSessionDelegate> delegate;
@property (nonatomic, retain) XFGroupController *groupController;

@property (readonly) XFSessionStatus status;

- (id)initWithDelegate:(id<XFSessionDelegate>)delegate;

- (void)setStatus:(XFSessionStatus)newStatus;

//--------------------------------------------------------------------------------
// Connecting to xfire
- (void)connect;
- (void)disconnect;

//--------------------------------------------------------------------------------
// Handling messages from the connection

- (void)loginFailed:(XFLoginError)reason;
- (void)connection:(XFConnection *)connection willDisconnect:(XFConnectionError)connectionError;

//--------------------------------------------------------------------------------
// Managing friends

- (void)raiseFriendNotification:(XFFriendNotification)notification forFriend:(XFFriend *)fr;

- (XFFriend *)friendForUserID:(unsigned int)userID;
- (XFFriend *)friendForUsername:(NSString *)username;
- (XFFriend *)friendForSessionID:(NSData *)sessionID;


/*
 * Don't be confused by the naming of these methods: they do not send an invitation nor
 * send a remove of a friend, these methods are usedto remove friends from these arrays
 * and can be used in several situations
 * Note: they automatically find out to which array the XFFriend object belongs
 */
- (void)addFriend:(XFFriend *)newFriend;
- (void)removeFriend:(XFFriend *)oldFriend;

/*
 * Now these methods actually handle friends deletion
 */
- (void)friendWasDeleted:(unsigned int)userID;

//--------------------------------------------------------------------------------
// User options

- (BOOL)shouldShowFriendsOfFriends;
- (BOOL)shouldShowOfflineFriends;

@end
